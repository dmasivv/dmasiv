import Foundation
import AVFoundation

/// Service for recording the user's voice to a local .m4a file.
class RecordAudio: NSObject, AVAudioRecorderDelegate {
    
    private var audioRecorder: AVAudioRecorder?
    
    /// URL of the most recently recorded file (set after stopRecording)
    private(set) var lastRecordingURL: URL?
    
    /// Whether the recorder is currently capturing audio
    var isCurrentlyRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    // MARK: - Recording
    /// Starts recording microphone input to a uniquely named .m4a file.
    /// Format: "SongTitle [Attempt X].m4a"
    func startRecording(songTitle: String = "Recording") throws {
        // 1. Configure audio session for recording + playback
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
        
        // 2. Build filename logic: "Title [Attempt 1].m4a"
        let directory = RecordAudio.recordingsDirectory()
        var attempt = 1
        
        // Buat nama file awal
        var fileName = "\(songTitle) [\(attempt)].m4a"
        var fileURL = directory.appendingPathComponent(fileName)
        
        // LOOPING: Cek terus menerus apakah file sudah ada.
        // Jika sudah ada, tambah attempt +1.
        while FileManager.default.fileExists(atPath: fileURL.path) {
            attempt += 1
            fileName = "\(songTitle) [\(attempt)].m4a"
            fileURL = directory.appendingPathComponent(fileName)
        }
        
        // 3. High-quality AAC recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // 4. Create recorder and start
        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
        
        lastRecordingURL = fileURL
        print("Recording started: \(fileURL.lastPathComponent)")
    }
    
    /// Stops the active recording and finalizes the file.
    @discardableResult
    func stopRecording() -> URL? {
        guard let recorder = audioRecorder, recorder.isRecording else {
            return lastRecordingURL
        }
        
        recorder.stop()
        print("Recording saved: \(lastRecordingURL?.lastPathComponent ?? "unknown")")
        return lastRecordingURL
    }
    
    // MARK: - File Management
    
    /// Returns the directory where all recordings are saved.
    static func recordingsDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordingsPath = documentsPath.appendingPathComponent("Recordings")
        
        if !FileManager.default.fileExists(atPath: recordingsPath.path) {
            try? FileManager.default.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
        }
        
        return recordingsPath
    }
    
    /// Returns a list of all saved recordings, sorted by creation date (newest first).
    static func getRecordings() -> [RecordingItem] {
        let directory = recordingsDirectory()
        
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
            options: .skipsHiddenFiles
        ) else {
            return []
        }
        
        return files
            .filter { $0.pathExtension == "m4a" }
            .compactMap { url -> RecordingItem? in
                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                let createdAt = attributes?[.creationDate] as? Date ?? Date()
                let fileSize = attributes?[.size] as? Int64 ?? 0
                
                return RecordingItem(
                    url: url,
                    name: url.deletingPathExtension().lastPathComponent,
                    createdAt: createdAt,
                    fileSize: fileSize
                )
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Deletes a specific recording file.
    static func deleteRecording(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("⚠️ Recording did not finish successfully")
        }
    }
}

// MARK: - Recording Data Model
struct RecordingItem: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let createdAt: Date
    let fileSize: Int64
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    var formattedDuration: String {
        let asset = AVURLAsset(url: url)
        let seconds = Int(CMTimeGetSeconds(asset.duration))
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM · h:mm a"
        return formatter.string(from: createdAt)
    }
}
