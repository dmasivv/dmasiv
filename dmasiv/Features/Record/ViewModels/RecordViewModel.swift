import Foundation
import AVFoundation
import SwiftUI

@MainActor
class RecordViewModel: ObservableObject {
    // BUKAN @Published (Aman dari EXC_BAD_ACCESS saat onAppear)
    private var currentSong: Song?
    
    @Published var isPlaying = false
    @Published var isRecording = false
    @Published var currentTime: TimeInterval = 0.0
    @Published var recordingDuration: TimeInterval = 0.0
    
    @Published var currentPitch: String = "--"
    @Published var currentMidiNote: Float = 0.0
    @Published var audioLevels: [CGFloat] = Array(repeating: 0.0, count: 20)
    @Published var pitchHistory: [PitchPoint] = []
    
    @Published var activeLyric: LyricLine?
    @Published var allNotes: [MIDINote] = []
    
    private var lyricsData: [LyricLine] = []
    private let pitchTracker = TrackUserPitch()
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    
    init() {
        setupPitchTracker()
    }
    
    func loadSong(_ song: Song) {
        self.currentSong = song
        
        // JEDA 0.1 DETIK: Membiarkan SwiftUI menggambar UI sebelum me-load file berat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lyricsData = LyricParser.parse(fileName: song.lyricFileName)
            
            // Asumsi file MIDI bernama sesuai lagu + "-midi"
            self.allNotes = MIDIParser.parse(fileName: song.vocalistFileName)
            
            if let url = Bundle.main.url(forResource: song.audioFileName, withExtension: "mp3") {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer?.prepareToPlay()
                } catch {
                    print("Error loading audio: \(error)")
                }
            }
        }
    }
    
    func requestMicrophonePermission() {
        AVAudioApplication.requestRecordPermission { _ in }
    }
    
    func togglePlayAndRecord() {
        if isPlaying {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func stopRecording() {
        isPlaying = false
        isRecording = false
        
        audioPlayer?.pause()
        audioPlayer?.currentTime = 0
        currentTime = 0.0
        recordingDuration = 0.0
        
        pitchTracker.stop()
        playbackTimer?.invalidate()
        
        currentMidiNote = 0.0
        currentPitch = "--"
        audioLevels = Array(repeating: 0.0, count: 20)
        activeLyric = nil
    }
    
    private func startRecording() {
        do {
            pitchHistory.removeAll()
            try pitchTracker.start()
            audioPlayer?.play()
            
            isPlaying = true
            isRecording = true
            
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.updatePlaybackProgress() }
            }
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func updatePlaybackProgress() {
        if let player = audioPlayer {
            currentTime = player.currentTime
        } else {
            currentTime += 0.05
        }
        recordingDuration += 0.05
        
        // Update Lyric
        if let nextLyricIndex = lyricsData.firstIndex(where: { $0.timestamp > currentTime }) {
            if nextLyricIndex > 0 { activeLyric = lyricsData[nextLyricIndex - 1] }
        } else {
            activeLyric = lyricsData.last
        }
    }
    
    private func setupPitchTracker() {
        pitchTracker.onPitchDetected = { [weak self] midiNote, pitchString, level in
            Task { @MainActor in
                guard let self = self, self.isRecording else { return }
                
                self.currentMidiNote = midiNote
                self.currentPitch = pitchString
                
                let safeLevel = level.isNaN ? 0.0 : CGFloat(level)
                self.audioLevels.removeFirst()
                self.audioLevels.append(safeLevel * 10.0)
                
                if midiNote > 0 {
                    self.pitchHistory.append(PitchPoint(time: self.recordingDuration, midiNote: midiNote))
                    
                    // AMAN DARI CRASH: Hapus memori titik nada yang sudah keluar layar (> 2 detik)
                    self.pitchHistory.removeAll(where: { (self.recordingDuration - $0.time) > 2.0 })
                }
            }
        }
    }
}
