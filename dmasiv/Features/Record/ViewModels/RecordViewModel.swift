import Foundation
import AVFoundation
import SwiftUI

enum RecordState{
    case stop
    case play
    case pause
}

@MainActor
class RecordViewModel: ObservableObject {
    // BUKAN @Published (Aman dari EXC_BAD_ACCESS saat onAppear)
    private var currentSong: Song?

    @Published var isPlaying = false
    @Published var isRecording = false
    @Published var currentTime: TimeInterval = 0.0
    @Published var recordingDuration: TimeInterval = 0.0
    @Published var songDuration: TimeInterval? = nil

    /// URL of the last saved vocal recording (set after pressing "Selesai")
    @Published var savedRecordingURL: URL? = nil
    /// Flag to show a "recording saved" confirmation
    @Published var showSavedConfirmation = false

    @Published var currentPitch: String = "--"
    @Published var currentMidiNote: Float = 0.0
    @Published var audioLevels: [CGFloat] = Array(repeating: 0.0, count: 50)
    @Published var pitchHistory: [PitchPoint] = []

    // Flag agar pitchHistory tidak dihapus saat resume (hanya dihapus saat start fresh)
    private var hasEverStarted = false

    @Published var activeLyric: LyricLine?
    @Published var allNotes: [MIDINote] = []
    @Published var allLyrics: [LyricLine] = []
    @Published var breathMarkers: [LyricLine] = []

    /// Progress karaoke lirik (0.0 – 1.0) untuk sweep warna
    var lyricProgress: CGFloat {
        guard let lyric = activeLyric else { return 0.0 }
        let rawProgress = (currentTime - lyric.startTime) / (lyric.endTime - lyric.startTime)
        return max(0.0, min(1.0, CGFloat(rawProgress)))
    }

    /// Index of the current lyric line in allLyrics
    var currentLyricIndex: Int? {
        allLyrics.lastIndex { currentTime >= $0.startTime }
    }

    private var lyricsData: [LyricLine] = [] { didSet { allLyrics = lyricsData } }
    private let pitchTracker = TrackUserPitch()
    private let voiceRecorder = RecordAudio()
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?

    init() {
        setupPitchTracker()
    }

    func loadSong(_ song: Song) {
        self.currentSong = song

        // JEDA 0.1 DETIK: Membiarkan SwiftUI menggambar UI sebelum me-load file berat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let parsedLyrics = LyricParser.parse(fileName: song.lyricFileName)
            
            // Simpan penanda napas terpisah untuk timeline
            self.breathMarkers = parsedLyrics.filter { $0.isBreathe }
            
            // Lirik murni tanpa BREATHE (hanya tampil di lyric card)
            self.lyricsData = parsedLyrics.filter { !$0.isBreathe }

            // Asumsi file MIDI bernama sesuai lagu + "-midi"
            self.allNotes = MIDIParser.parse(fileName: song.vocalistFileName)

            if let url = Bundle.main.url(forResource: song.audioFileName, withExtension: "mp3") {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer?.prepareToPlay()
                    self.songDuration = self.audioPlayer?.duration
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
            pauseRecording()   // CHANGED: pause di posisi saat ini, tidak reset ke awal
        } else {
            startRecording()
        }
    }

    /// Pause audio di posisi saat ini tanpa mereset currentTime.
    func pauseRecording() {
        isPlaying = false
        isRecording = false

        audioPlayer?.pause()        // pause tanpa reset posisi
        pitchTracker.stop()
        playbackTimer?.invalidate()

        currentMidiNote = 0.0
        currentPitch = "--"
        audioLevels = Array(repeating: 0.0, count: 50)
    }

    /// Restart rekaman dari awal lagu.
    func replayRecording() {
        stopRecording()             // reset posisi ke 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            Task { @MainActor in
                self.startRecording()
            }
        }
    }

    func stopRecording() {
        hasEverStarted = false      // reset flag agar next start bersihkan pitchHistory
        isPlaying = false
        isRecording = false

        audioPlayer?.pause()
        audioPlayer?.currentTime = 0
        currentTime = 0.0
        recordingDuration = 0.0

        pitchTracker.stop()
        playbackTimer?.invalidate()

        // Save the vocal recording
        if let url = voiceRecorder.stopRecording() {
            savedRecordingURL = url
            showSavedConfirmation = true
        }

        currentMidiNote = 0.0
        currentPitch = "--"
        audioLevels = Array(repeating: 0.0, count: 50)
        activeLyric = nil
    }

    /// Melompat ke waktu tertentu (seek) saat user menggeser slider
    func seek(to time: TimeInterval) {
        guard let player = audioPlayer, let duration = songDuration else { return }
        let clampedTime = max(0, min(time, duration))
        
        player.currentTime = clampedTime
        currentTime = clampedTime
        
        // Sinkronisasi lirik agar langsung melompat
        if let currentL = lyricsData.first(where: { clampedTime >= $0.startTime && clampedTime <= $0.endTime }) {
            activeLyric = currentL
        } else {
            activeLyric = nil
        }
    }

    func startRecording() {
        do {
            // Hanya hapus history saat start fresh, bukan saat resume dari pause
            if !hasEverStarted {
                pitchHistory.removeAll()
                savedRecordingURL = nil
                showSavedConfirmation = false
                hasEverStarted = true
            }

            try pitchTracker.start()

            // Start recording the user's voice
            let songTitle = currentSong?.title ?? "Recording"
            try voiceRecorder.startRecording(songTitle: songTitle)

            audioPlayer?.play()

            isPlaying = true
            isRecording = true

            // Timer sinkronisasi menggunakan waktu dari MP3 (Master Clock)
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
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
            currentTime += 0.016
        }
        recordingDuration += 0.016

        // Update Active Lyric (sama seperti prototype MIDIPlayerManager)
        if let currentL = lyricsData.first(where: { currentTime >= $0.startTime && currentTime <= $0.endTime }) {
            if activeLyric?.id != currentL.id {
                activeLyric = currentL
            }
        } else {
            activeLyric = nil
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
                self.audioLevels.append(safeLevel)

                if midiNote > 0 {
                    self.pitchHistory.append(PitchPoint(time: self.recordingDuration, midiNote: midiNote))

                    // AMAN DARI CRASH: Hapus memori titik nada yang sudah keluar layar (> 2 detik)
                    self.pitchHistory.removeAll(where: { (self.recordingDuration - $0.time) > 2.0 })
                }
            }
        }
    }
}
