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

#Preview {
    HistoryView()
}
