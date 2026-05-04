import SwiftUI
import AVFoundation

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @StateObject private var playbackManager = AudioPlaybackManager()
    
    // State khusus untuk urusan navigasi/modal UI
    @State private var selectedRecording: RecordingItem? = nil
    @State private var showDeleteAlert = false
    @State private var recordingToDelete: RecordingItem? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.recordings.isEmpty {
                    HistoryEmptyView()
                } else {
                    HistoryListView(recordings: viewModel.recordings) { recording in
                        selectedRecording = recording
                    }
                }
            }
            .navigationTitle("History")
            .onAppear { viewModel.fetchRecordings() }
            
            // Modal Lagu
            .sheet(item: $selectedRecording) { recording in
                PlaybackModalView(
                    recording: recording,
                    manager: playbackManager,
                    onDelete: {
                        recordingToDelete = recording
                        showDeleteAlert = true
                    }
                )
                .presentationDetents([.height(400), .medium])
                .presentationDragIndicator(.visible)
            }
            
            // Alert untuk hapus
            .alert("Hapus Rekaman?", isPresented: $showDeleteAlert) {
                Button("Hapus", role: .destructive) {
                    if let item = recordingToDelete {
                        viewModel.deleteRecording(item)
                    }
                }
                Button("Batal", role: .cancel) {}
            }
        }
    }
}


// Tampilan saat tidak ada rekaman sama sekali
struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Belum ada rekaman")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

// Tampilan List untuk me-looping file rekaman
struct HistoryListView: View {
    let recordings: [RecordingItem]
    let onSelect: (RecordingItem) -> Void
    
    var body: some View {
        List {
            ForEach(recordings) { recording in
                RecordingRow(recording: recording) {
                    onSelect(recording) // Lempar lagu yang ditekan ke tampilan utama
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// View card rekaman lagu
struct RecordingRow: View {
    let recording: RecordingItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Ikon Musik Kiri
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "music.mic")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
                
                // Teks Informasi
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(recording.formattedDate)
                        Text("•")
                        Text(recording.formattedSize)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Ikon Play
                Image(systemName: "play.circle")
                    .font(.title3)
                    .foregroundColor(.blue.opacity(0.8))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct PlaybackModalView: View {
    let recording: RecordingItem
    @ObservedObject var manager: AudioPlaybackManager
    let onDelete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Info Lagu
                VStack(spacing: 8) {
                    Text(recording.name)
                        .font(.title2.bold())
                        .lineLimit(1)
                    Text(recording.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                
                // Slider Timeline
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { manager.currentTime },
                            set: { newValue in manager.seek(to: newValue) }
                        ),
                        in: 0...max(manager.duration, 0.01)
                    )
                    .tint(.blue)
                    
                    HStack {
                        Text(formatTime(manager.currentTime))
                        Spacer()
                        Text("-" + formatTime(manager.duration - manager.currentTime))
                    }
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 32)
                
                // Kontrol Playback (Prev 10s, Play/Pause, Next 10s)
                HStack(spacing: 40) {
                    Button(action: { manager.skipBackward() }) {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 28))
                    }
                    
                    Button(action: { manager.togglePlayPause() }) {
                        Image(systemName: manager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 64))
                    }
                    
                    Button(action: { manager.skipForward() }) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 28))
                    }
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            .onAppear { manager.load(url: recording.url) }
            .onDisappear { manager.stop() }
            
            // Toolbar Atas Modal
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Tutup") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDelete()
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && !time.isInfinite else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    HistoryView()
}
