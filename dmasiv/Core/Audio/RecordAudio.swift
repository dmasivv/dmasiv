import Foundation
import AVFoundation

/// Service for recording the user's voice to a local .m4a file.
///
/// Usage:
/// 1. Call `startRecording(songTitle:)` when the karaoke session begins.
/// 2. Call `stopRecording()` when the user presses "Selesai".
/// 3. The file is saved to the app's Documents directory and can be played back
///    via `getRecordings()` + AVAudioPlayer.
class RecordAudio: NSObject, AVAudioRecorderDelegate {
    
    private var audioRecorder: AVAudioRecorder?
    
    /// URL of the most recently recorded file (set after stopRecording)
    private(set) var lastRecordingURL: URL?
    
    /// Whether the recorder is currently capturing audio
    var isCurrentlyRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    // MARK: - Recording
    
    /// Starts recording microphone input to a timestamped .m4a file.
    /// - Parameter songTitle: Used as a prefix in the filename for easy identification.
    /// - Throws: If the audio session or recorder setup fails.
    func startRecording(songTitle: String = "Recording") throws {
        // 1. Configure audio session for recording + playback
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
        
        // 2. Build a unique filename: "Januari_2026-05-02_13-22-35.m4a"
        let sanitizedTitle = songTitle.replacingOccurrences(of: " ", with: "_")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "\(sanitizedTitle)_\(timestamp).m4a"
        
        let fileURL = RecordAudio.recordingsDirectory().appendingPathComponent(fileName)
        
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
        print("🎙️ Recording started: \(fileURL.lastPathComponent)")
    }
    
    /// Stops the active recording and finalizes the file.
    /// - Returns: The URL of the saved recording, or nil if nothing was recording.
    @discardableResult
    func stopRecording() -> URL? {
        guard let recorder = audioRecorder, recorder.isRecording else {
            return lastRecordingURL
        }
        
        recorder.stop()
        print("🎙️ Recording saved: \(lastRecordingURL?.lastPathComponent ?? "unknown")")
        return lastRecordingURL
    }
    
    // MARK: - File Management
    
    /// Returns the directory where all recordings are saved.
    /// Creates the directory if it doesn't exist.
    static func recordingsDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordingsPath = documentsPath.appendingPathComponent("Recordings")
        
        // Create directory if needed
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

/// Represents a saved recording file with metadata.
struct RecordingItem: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let createdAt: Date
    let fileSize: Int64
    
    /// Human-readable file size (e.g. "1.2 MB")
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    /// Human-readable date (e.g. "2 May 2026, 13:22")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}
