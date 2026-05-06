import SwiftUI

struct RecordView: View {
    let song: Song
    
    // 1. Terima binding dari SongListView
    @Binding var selectedTab: Int
    @Binding var shouldAutoPlayNewest: Bool
    
    @StateObject private var viewModel = RecordViewModel()
    @State private var navigateToResult = false
    
    // 2. Gunakan environment untuk menutup (dismiss) halaman ini
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.06, blue: 0.14)
                .ignoresSafeArea()

            // Catatan: NavigationLink ke HistoryView DIHAPUS karena kita akan langsung melompat ke Tab 1

            VStack(spacing: 16) {
                RecordHeaderViewV2(song: song)

                BreathTimelineView(viewModel: viewModel)
                    .padding(.horizontal, 20)

                LyricCardViewV2(viewModel: viewModel)
                    .padding(.bottom, 10)

                PlaybackProgressView(viewModel: viewModel)
                    .padding(.horizontal, 8)

                WaveformVisualizerViewV2(viewModel: viewModel)
                    .padding(.horizontal, 24)

                RecordControlsViewV2(viewModel: viewModel, navigateToResult: $navigateToResult)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                viewModel.requestMicrophonePermission()
            }
            viewModel.loadSong(song)
        }
        // 3. Tangkap perubahan navigateToResult dari tombol Stop
        .onChange(of: navigateToResult) { newValue in
            if newValue {
                // 2. Aktifkan sinyal auto-play
                shouldAutoPlayNewest = true
                
                dismiss()
                selectedTab = 1
            }
        }
    }
}

#Preview {
    // Berikan nilai konstan untuk keperluan preview Canvas
    RecordView(song: .Januari, selectedTab: .constant(0), shouldAutoPlayNewest: .constant(false))
}
