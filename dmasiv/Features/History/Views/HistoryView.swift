import SwiftUI
import AVFoundation

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @StateObject private var playbackManager = AudioPlaybackManager()
    
    // Tangkap sinyal dari SongListView
    @Binding var shouldAutoPlayNewest: Bool

    @State private var selectedRecording: RecordingItem? = nil
    @State private var showDeleteAlert = false
    @State private var recordingToDelete: RecordingItem? = nil
    
    private let bgColor = Color(red: 0.04, green: 0.06, blue: 0.14)

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
            .onAppear {
                viewModel.fetchRecordings()
                checkAutoPlaySignal() // Cek saat tab History baru pertama kali dirender
            }
            // Cek saat tab History sudah dirender sebelumnya dan user dialihkan ke sini
            .onChange(of: shouldAutoPlayNewest) { newValue in
                if newValue {
                    checkAutoPlaySignal()
                }
            }
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
    
    // Fungsi untuk mengecek sinyal dan membuka rekaman terbaru
    private func checkAutoPlaySignal() {
        if shouldAutoPlayNewest {
            // Beri jeda sedikit agar animasi perpindahan tab selesai dengan mulus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Pastikan data terbaru sudah difetch
                viewModel.fetchRecordings()
                
                // Ambil rekaman pertama (asumsi index 0 adalah yang paling baru)
                if let newestRecording = viewModel.recordings.first {
                    selectedRecording = newestRecording
                }
                
                // Reset sinyal agar tidak terus-terusan terbuka
                shouldAutoPlayNewest = false
            }
        }
    }
}

#Preview {
    // Berikan nilai dummy .constant(false) agar Preview tidak error
    HistoryView(shouldAutoPlayNewest: .constant(false))
}
