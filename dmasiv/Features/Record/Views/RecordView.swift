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
                    Gradient.Stop(color: Color(red: 0.16, green: 0.25, blue: 0.50), location: 0.0),   // Atas: Terangnya sedikit diturunkan agar lebih soft
                    Gradient.Stop(color: Color(red: 0.10, green: 0.15, blue: 0.35), location: 0.25),  // Jarak transisi diperpanjang agar lebih smooth
                    Gradient.Stop(color: Color(red: 0.10, green: 0.15, blue: 0.35), location: 0.45),  // Area gelap tetap luas
                    Gradient.Stop(color: Color(red: 0.15, green: 0.23, blue: 0.48), location: 1.0)    // Bawah: Kembali menerang (soft)
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

                // ── Lyric Card (desain baru) ───────────────────────────────
                LyricCardViewV2(viewModel: viewModel)

                Spacer()

                // ── Playback Progress Slider ───────────────────────────────
                PlaybackProgressView(viewModel: viewModel)
                    .padding(.horizontal, 8)

                // ── Waveform Visualizer (desain baru) ─────────────────────
                WaveformVisualizerViewV2(viewModel: viewModel)
                    .padding(.horizontal, 24)

                // ── Controls: Replay + Mic ────────────────────────────────
                RecordControlsViewV2(viewModel: viewModel, navigateToResult: $navigateToResult)
            }

            /* ── Komponen lama (di-disable, TIDAK dihapus) ─────────────────
            VStack(spacing: 20) {
                // Nama Lagu dan Artis
                SongTitleAndArtist(title: song.title, artist: song.artist)

                // Imitasi Smule
                TimelineAreaView(viewModel: viewModel)
                    .padding(.horizontal)

                // Lirik Musik
                RefinedLyricAndBreathingNotation(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Feedback Visual Suara
                WaveformVisualizerView(viewModel: viewModel)
                    .padding(.horizontal)

                // Button Start
                RecordControlsView(viewModel: viewModel, navigateToResult: $navigateToResult)
            }
            ─────────────────────────────────────────────────────────────── */
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Mencegah Preview (Canvas) minta izin Mic yang bisa bikin Crash
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                viewModel.requestMicrophonePermission()
            }
            viewModel.loadSong(song)
        }
    }
}

// MARK: - Preview
#Preview {
    RecordView(song: .Januari)
}
