import SwiftUI

// MARK: - Main View
/// The primary recording screen.
struct RecordView: View {
    let song: Song

    // Binding untuk navigasi antar-tab
    @Binding var selectedTab: Int
    @Binding var shouldAutoPlayNewest: Bool

    @StateObject private var viewModel = RecordViewModel()
    @Environment(\.dismiss) private var dismiss

    // State untuk onboarding overlay
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            // ── Background ──
            Color(red: 0.04, green: 0.06, blue: 0.14)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // ── Header ────────────────────────────────────────────────
                RecordHeaderViewV2(song: song)

                // ── Breath Timeline ───────────────────────────────────────
                BreathTimelineView(viewModel: viewModel)
                    .padding(.horizontal, 35)

                // ── Lyric Card ────────────────────────────────────────────
                LyricCardViewV2(viewModel: viewModel)
                    .padding(.bottom, 10)

                // ── Playback Progress Slider ──────────────────────────────
                PlaybackProgressView(viewModel: viewModel)
                    .padding(.horizontal, 8)

                // ── Waveform Visualizer ───────────────────────────────────
                WaveformVisualizerViewV2(viewModel: viewModel)
                    .padding(.horizontal, 24)

                // ── Controls: Replay + Mic/Pause ──────────────────────────
                RecordControlsViewV2(
                    viewModel: viewModel,
                    onPause: { handlePause() }
                )
            }

            // ── Onboarding Overlay ────────────────────────────────────
            if showOnboarding {
                // Dim background
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showOnboarding = false
                        }
                    }

                // Onboarding card
                TimelineOnboardingView(
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showOnboarding = false
                        }
                    },
                    onNeverShow: {
                        UserDefaults.standard.set(true, forKey: "hasSeenTimelineOnboarding")
                        withAnimation(.easeOut(duration: 0.25)) {
                            showOnboarding = false
                        }
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.88).combined(with: .opacity),
                        removal:   .scale(scale: 0.92).combined(with: .opacity)
                    )
                )
                .padding(.horizontal, 28)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: showOnboarding)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                viewModel.requestMicrophonePermission()
            }
            viewModel.loadSong(song)

            // Tampilkan onboarding jika belum pernah di-dismiss permanen
            let seen = UserDefaults.standard.bool(forKey: "hasSeenTimelineOnboarding")
            if !seen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showOnboarding = true
                    }
                }
            }
        }
    }

    /// Dipanggil saat tombol Pause ditekan:
    /// stop + simpan rekaman ke disk, lalu pindah ke tab History dan auto-play rekaman terbaru.
    private func handlePause() {
        // stopRecording() menyimpan file vokal ke disk (voiceRecorder.stopRecording())
        viewModel.stopRecording()

        // Beri jeda singkat agar file selesai ditulis ke disk sebelum navigasi
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shouldAutoPlayNewest = true
            dismiss()
            selectedTab = 1
        }
    }
}

#Preview {
    RecordView(
        song: .Januari,
        selectedTab: .constant(0),
        shouldAutoPlayNewest: .constant(false)
    )
}
