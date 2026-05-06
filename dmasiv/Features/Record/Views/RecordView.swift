import SwiftUI

// MARK: - Main View
/// The primary recording screen.
/// Assembles header, lyrics, waveform visualizer, and playback controls.
/// All sub-views live in `RecordView-UIComponents.swift`.
struct RecordView: View {
    let song: Song
    
    // 1. Terima binding dari SongListView untuk sinkronisasi Tab & Modal
    @Binding var selectedTab: Int
    @Binding var shouldAutoPlayNewest: Bool
    
    @StateObject private var viewModel = RecordViewModel()
    @State private var navigateToResult = false
    @State private var showTimelineOnboarding = false
    @State private var hasShownOnboardingThisSession = false
    
    // 2. Gunakan environment untuk menutup (dismiss) halaman ini
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // ── Background solid sesuai SongListView ──
            Color(red: 0.04, green: 0.06, blue: 0.14)
                .ignoresSafeArea()

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

            if showTimelineOnboarding {
                // Dim scrim — full bleed, no tap-to-dismiss
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .transition(.opacity)

                // Onboarding card
                TimelineOnboardingView(
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showTimelineOnboarding = false
                        }
                    },
                    onNeverShow: {
                        UserDefaults.standard.set(true, forKey: "hasSeenTimelineOnboarding")
                        withAnimation(.easeOut(duration: 0.25)) {
                            showTimelineOnboarding = false
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
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: showTimelineOnboarding)
        .navigationBarTitleDisplayMode(.inline)
        // Menyembunyikan background bawaan navigation bar agar gradient bisa tembus ke atas
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            // Mencegah Preview (Canvas) minta izin Mic yang bisa bikin Crash
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                viewModel.requestMicrophonePermission()
            }
            viewModel.loadSong(song)

            // Defensive pause if song somehow already playing
            if viewModel.isPlaying { viewModel.pauseRecording() }

            // Show onboarding once per session, unless permanently dismissed
            let seen = UserDefaults.standard.bool(forKey: "hasSeenTimelineOnboarding")
            if !seen && !hasShownOnboardingThisSession {
                hasShownOnboardingThisSession = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        showTimelineOnboarding = true
                    }
                }
            }
        }
        // ── LISTENER 1: Saat tombol manual STOP (kotak) diklik ──
        .onChange(of: navigateToResult) { oldValue, newValue in
            if newValue {
                // Aktifkan sinyal auto-play
                shouldAutoPlayNewest = true
                
                // Tutup halaman RecordView (akan kembali ke Library)
                dismiss()
                // Pindah secara otomatis ke Tab History
                selectedTab = 1
            }
        }
        // ── LISTENER 2: Saat lagu selesai dengan sendirinya (Auto-Stop) ──
        .onChange(of: viewModel.isSongFinished) { oldValue, newValue in
            if newValue {
                // Aktifkan sinyal auto-play
                shouldAutoPlayNewest = true
                
                // Tutup halaman RecordView (akan kembali ke Library)
                dismiss()
                // Pindah secara otomatis ke Tab History
                selectedTab = 1
            }
        }
    }
}

#Preview {
    // Berikan nilai konstan untuk keperluan preview Canvas
    RecordView(
        song: .Januari, // Ganti dengan dummy lagu kamu jika error
        selectedTab: .constant(0),
        shouldAutoPlayNewest: .constant(false)
    )
}
