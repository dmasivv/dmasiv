import SwiftUI
import AVFoundation

/// A standalone view to browse, play back, and delete saved vocal recordings.
/// Useful for testing that the recording feature works correctly.
///
/// Navigate here from anywhere:
/// ```swift
/// NavigationLink("Rekaman Saya") { RecordingsListView() }
/// ```
struct RecordingsListView: View {
    @State private var recordings: [RecordingItem] = []
    @State private var playingURL: URL? = nil
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var showDeleteAlert = false
    @State private var recordingToDelete: RecordingItem? = nil
    
    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.08, blue: 0.15).ignoresSafeArea()
            
            if recordings.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "waveform.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.3))
                    Text("Belum ada rekaman")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Mulai menyanyi dan tekan \"Selesai\"\nuntuk menyimpan rekaman.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                }
            } else {
                List {
                    ForEach(recordings) { recording in
                        RecordingRow(
                            recording: recording,
                            isPlaying: playingURL == recording.url,
                            onPlay: { togglePlayback(recording) },
                            onDelete: {
                                recordingToDelete = recording
                                showDeleteAlert = true
                            }
                        )
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Rekaman Saya")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { loadRecordings() }
        .alert("Hapus Rekaman?", isPresented: $showDeleteAlert) {
            Button("Hapus", role: .destructive) {
                if let item = recordingToDelete {
                    deleteRecording(item)
                }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Rekaman \"\(recordingToDelete?.name ?? "")\" akan dihapus permanen.")
        }
    }
    
    
    // MARK: - Actions
    
    private func loadRecordings() {
        recordings = RecordAudio.getRecordings()
    }
    
    private func togglePlayback(_ recording: RecordingItem) {
        // If already playing this file, stop
        if playingURL == recording.url {
            audioPlayer?.stop()
            audioPlayer = nil
            playingURL = nil
            return
        }
        
        // Stop any previous playback
        audioPlayer?.stop()
        
        do {
            // Configure session for playback
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.play()
            playingURL = recording.url
        } catch {
            print("⚠️ Playback error: \(error)")
            playingURL = nil
        }
    }
    
    private func deleteRecording(_ recording: RecordingItem) {
        if playingURL == recording.url {
            audioPlayer?.stop()
            audioPlayer = nil
            playingURL = nil
        }
        RecordAudio.deleteRecording(at: recording.url)
        loadRecordings()
    }
}

// MARK: - Recording Row

/// A single row in the recordings list, showing name, date, size, and play/delete controls.
struct RecordingRow: View {
    let recording: RecordingItem
    let isPlaying: Bool
    let onPlay: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Play / Stop button
            Button(action: onPlay) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            
            // Recording info
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(recording.formattedDate)
                    Text("•")
                    Text(recording.formattedSize)
                }
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        RecordingsListView()
    }
}
