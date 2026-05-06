import SwiftUI

// MARK: - Main View
/// The primary recording screen.
/// Assembles header, lyrics, waveform visualizer, and playback controls.
/// All sub-views live in `RecordView-UIComponents.swift`.
struct RecordView: View {
    let song: Song
    @StateObject private var viewModel = RecordViewModel()
    @State private var navigateToResult = false

    var body: some View {
        ZStack {
            // ── Background solid sesuai SongListView ──
            Color(red: 0.04, green: 0.06, blue: 0.14)
                .ignoresSafeArea()

            // Hidden Navigation ke Page 3
            NavigationLink(destination: Text("Halaman Result"), isActive: $navigateToResult) {
                EmptyView()
            }

            VStack(spacing: 16) {
                // ── Header: Album Art + Judul + Artis ─────────────────────
                RecordHeaderViewV2(song: song)

                // ── Breath Timeline (menunjukkan kapan harus napas) ───────
                BreathTimelineView(viewModel: viewModel)
                    .padding(.horizontal, 35)

                // ── Lyric Card (desain baru) ───────────────────────────────
                LyricCardViewV2(viewModel: viewModel)
                    .padding(.bottom, 10)

                // ── Playback Progress Slider ───────────────────────────────
                PlaybackProgressView(viewModel: viewModel)
                    .padding(.horizontal, 8)

                // ── Waveform Visualizer (desain baru) ─────────────────────
                WaveformVisualizerViewV2(viewModel: viewModel)
                    .padding(.horizontal, 24)

                // ── Controls: Replay + Mic ────────────────────────────────
                RecordControlsViewV2(viewModel: viewModel, navigateToResult: $navigateToResult)
            }

        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Mencegah Preview (Canvas) minta izin Mic yang bisa bikin Crash
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                viewModel.requestMicrophonePermission()
            }
            viewModel.loadSong(song)
        }
    }
}

#Preview {
    RecordView(song: .Januari)
}
