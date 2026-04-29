import Foundation
import AVFoundation
import Accelerate

class TrackUserPitch {
    private let audioEngine = AVAudioEngine()
    var onPitchDetected: ((Float, String, Float) -> Void)?
    
    func start() throws {
        // 1. SETUP AUDIO SESSION TERLEBIH DAHULU (Mencegah Crash Format)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true)
        
        let inputNode = audioEngine.inputNode
        
        // 2. Ambil format SETELAH hardware menyala
        let format = inputNode.outputFormat(forBus: 0)
        
        // 3. Hapus Tap Lama (Mencegah Crash Tap)
        inputNode.removeTap(onBus: 0)
        
        // 4. Mulai merekam
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            self?.processAudioData(buffer: buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }

    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
    
    private func processAudioData(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frames = Int(buffer.frameLength)
        
        // AMAN DARI CRASH: Jika mikrofon mengirim buffer kosong, lewati!
        guard frames > 0 else { return }
        
        let sampleRate = Float(buffer.format.sampleRate)
        guard sampleRate > 0 else { return } // Mencegah pembagian 0
        
        // 1. Calculate Amplitude (Volume)
        var rms: Float = 0.0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frames))
        
        // AMAN DARI CRASH: Cegah pengiriman nilai NaN (Not a Number) ke SwiftUI
        guard !rms.isNaN && !rms.isInfinite else { return }
        
        let decibels = 20.0 * log10(rms)
        let level = max(0.0, CGFloat(decibels) + 50.0) / 50.0
        
        var noteString = "--"
        var rawMidiNote: Float = 0.0
        
        // Noise Gate: Set to 0.05 so it catches fading, sustained notes
        if rms > 0.05 {
            let minFreq: Float = 80.0
            let maxFreq: Float = 1000.0
            
            let minLag = Int(sampleRate / maxFreq)
            let maxLag = Int(sampleRate / minFreq)
            let validMaxLag = min(maxLag, frames - 1)
            
            var correlations = [Float](repeating: 0.0, count: validMaxLag)
            var maxCorrelation: Float = 0.0
            
            // 2. Normalized Autocorrelation (Fixes math bias towards high notes)
            for lag in minLag..<validMaxLag {
                var correlation: Float = 0.0
                let elementsToProcess = frames - lag
                
                // Hardware-accelerated vector multiplication
                vDSP_dotpr(channelData, 1, channelData.advanced(by: lag), 1, &correlation, vDSP_Length(elementsToProcess))
                
                // Normalize by dividing by the number of elements processed
                correlation /= Float(elementsToProcess)
                correlations[lag] = correlation
                
                if correlation > maxCorrelation {
                    maxCorrelation = correlation
                }
            }
            
            // 3. Smart Peak Picking / Harmonic Suppression (Fixes Octave Jumps)
            // Turunkan threshold sedikit ke 85% karena head voice kadang lebih tipis sinyalnya
            let threshold = maxCorrelation * 0.85
            var bestLag = 0
            
            // PERBAIKAN: Scan MAJU dari shortest lag (nada tertinggi) ke longest lag (nada terendah)
            for lag in minLag..<validMaxLag {
                if correlations[lag] > threshold {
                    // Check if it's a true local peak (higher than its immediate neighbors)
                    if lag > 0 && lag < validMaxLag - 1 {
                                    if correlations[lag] > correlations[lag - 1] && correlations[lag] > correlations[lag + 1] {
                                        bestLag = lag
                                        break // Berhasil mengunci nada fundamental yang asli!
                                    }
                                }
                            }
                        }
            
            let frequency = bestLag > 0 ? Double(sampleRate) / Double(bestLag) : 0.0
            
            // 4. Convert Frequency to Musical Note
            if frequency > 80.0 && frequency < 1000.0 {
                let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
                let frequencyRatio = frequency / 440.0
                let logValue = log2(frequencyRatio)
                
                rawMidiNote = Float(12.0 * logValue + 69.0)
                let pitchIndex = Int(round(rawMidiNote))
                
                if pitchIndex >= 0 {
                    let note = notes[pitchIndex % 12]
                    let octave = (pitchIndex / 12) - 1
                    noteString = "\(note)\(octave)"
                }
            }
        }
        
        // Kirim hasil kembali ke ViewModel di Main Thread (level = dB-normalized 0.0-1.0)
        DispatchQueue.main.async {
            self.onPitchDetected?(rawMidiNote, noteString, Float(level))
        }
    }
}
