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
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Judul "History" kustom — tanpa navigation bar bawaan ──
                    Text("History")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 16)

                    if viewModel.recordings.isEmpty {
                        HistoryEmptyView()
                            .padding(.top, 40)
                    } else {
                        HistoryListView(recordings: viewModel.recordings) { recording in
                            selectedRecording = recording
                        }
                    }
                }
            }
            .background(Color(red: 0.04, green: 0.06, blue: 0.14).ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar) // Sembunyikan nav bar bawaan
            .preferredColorScheme(.dark)
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
