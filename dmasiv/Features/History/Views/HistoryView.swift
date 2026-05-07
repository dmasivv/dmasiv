import SwiftUI
import AVFoundation

struct HistoryView: View {
    @Binding var shouldAutoPlayNewest: Bool

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
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .onAppear {
                // Jika ada sinyal auto-play masuk (tab dibuka dari RecordView via Pause)
                if shouldAutoPlayNewest {
                    shouldAutoPlayNewest = false
                    openNewest()
                } else {
                    viewModel.fetchRecordings()
                }
            }
            // Fallback: tangkap sinyal jika History sudah ter-load sebelumnya
            .onChange(of: shouldAutoPlayNewest) { newValue in
                guard newValue else { return }
                shouldAutoPlayNewest = false
                openNewest()
            }

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

    // MARK: - Helper

    /// Fetch ulang daftar rekaman lalu buka modal rekaman paling baru.
    /// Menggunakan dua tahap delay untuk memastikan file sudah tersimpan ke disk.
    private func openNewest() {
        // Tahap 1: coba setelah 0.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            viewModel.fetchRecordings()
            if let newest = viewModel.recordings.first {
                selectedRecording = newest
                return
            }
            // Tahap 2: jika belum ada (file masih ditulis), coba lagi setelah 1.2s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                viewModel.fetchRecordings()
                if let newest = viewModel.recordings.first {
                    selectedRecording = newest
                }
            }
        }
    }
}

#Preview {
    HistoryView(shouldAutoPlayNewest: .constant(false))
}

