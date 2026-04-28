import Foundation
import AVFoundation

class TrackUserPitch {
    private let audioEngine = AVAudioEngine()
    var onPitchDetected: ((Float, String, Float) -> Void)?
    
    func start() throws {
        // 1. SETUP AUDIO SESSION TERLEBIH DAHULU (Mencegah Crash Format)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
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
        
        var rms: Float = 0.0
        for i in 0..<frames {
            rms += channelData[i] * channelData[i]
        }
        rms = sqrt(rms / Float(frames))
        
        // AMAN DARI CRASH: Cegah pengiriman nilai NaN (Not a Number) ke SwiftUI
        guard !rms.isNaN && !rms.isInfinite else { return }
        
        if rms > 0.07 { // Noise Gate threshold
            if let frequency = detectPitch(channelData: channelData, frames: frames, sampleRate: sampleRate) {
                let midiNote = frequencyToMIDINote(frequency)
                let pitchString = midiNoteToString(Int(round(midiNote)))
                
                DispatchQueue.main.async {
                    self.onPitchDetected?(midiNote, pitchString, rms)
                }
            } else {
                DispatchQueue.main.async { self.onPitchDetected?(0.0, "--", rms) }
            }
        } else {
            DispatchQueue.main.async { self.onPitchDetected?(0.0, "--", rms) }
        }
    }
    
    private func detectPitch(channelData: UnsafeMutablePointer<Float>, frames: Int, sampleRate: Float) -> Float? {
        var maxVal: Float = 0.0
        var maxLag: Int = 0
        
        let minFreq: Float = 80.0
        let maxFreq: Float = 1000.0
        
        let minLag = Int(sampleRate / maxFreq)
        let maxLagLimit = Int(sampleRate / minFreq)
        let limit = min(frames, maxLagLimit)
        
        for lag in minLag..<limit {
            var sum: Float = 0.0
            for i in 0..<(frames - lag) {
                sum += channelData[i] * channelData[i + lag]
            }
            if sum > maxVal {
                maxVal = sum
                maxLag = lag
            }
        }
        
        guard maxLag > 0 else { return nil }
        return sampleRate / Float(maxLag)
    }
    
    private func frequencyToMIDINote(_ frequency: Float) -> Float {
        return 69.0 + 12.0 * log2(frequency / 440.0)
    }
    
    private func midiNoteToString(_ midiNote: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let clampedMidi = max(0, min(127, midiNote))
        let octave = (clampedMidi / 12) - 1
        let noteIndex = clampedMidi % 12
        return "\(noteNames[noteIndex])\(octave)"
    }
}
