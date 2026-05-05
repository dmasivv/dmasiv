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
            // ── Background: atas agak terang, tengah gelap, bawah kembali terang (soft) ──
            LinearGradient(
                stops: [
                    Gradient.Stop(color: AppColors.backgroundTop, location: 0.0),
                    Gradient.Stop(color: AppColors.backgroundMid, location: 0.25),
                    Gradient.Stop(color: AppColors.backgroundMid, location: 0.45),
                    Gradient.Stop(color: AppColors.backgroundBottom, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
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
                    .padding(.horizontal, 20)

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
        // Menyembunyikan background bawaan navigation bar agar gradient bisa tembus ke atas
        .toolbarBackground(.hidden, for: .navigationBar)
        // Jika tidak ingin ada tulisan 'Back' yang mengganggu, bisa gunakan custom back atau hide toolbar
        // .toolbar(.hidden, for: .navigationBar)
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
