import SwiftUI

// ============================================================
// MARK: - V2 Playback Progress Slider
// ============================================================

/// Slider progress lagu dengan timestamp kiri (elapsed) dan kanan (total).
struct PlaybackProgressView: View {
    @ObservedObject var viewModel: RecordViewModel

    // State lokal saat user menahan/menggeser slider
    @State private var dragProgress: CGFloat? = nil

    private var progress: CGFloat {
        if let dp = dragProgress { return dp }
        guard let duration = viewModel.songDuration, duration > 0 else { return 0 }
        return CGFloat(viewModel.currentTime / duration)
    }

    var body: some View {
        HStack(spacing: 10) {
            // Tampilkan waktu sementara jika sedang digeser, atau waktu asli lagu jika tidak
            let displayedTime = dragProgress != nil ? (Double(dragProgress!) * (viewModel.songDuration ?? 0)) : viewModel.currentTime
            Text(formatTime(displayedTime))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(AppColors.labelDim)
                .frame(width: 36, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(AppColors.overlayTrack)
                        .frame(height: 4)

                    // Filled portion (Gradien biru ke putih)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.accentBlue, AppColors.lyricActive],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * progress), height: 4)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                    // Thumb
                    Circle()
                        .fill(AppColors.lyricActive)
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                        .scaleEffect(dragProgress != nil ? 1.3 : 1.0)
                        .offset(x: (geo.size.width * progress) - 7)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: dragProgress != nil)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newProgress = max(0, min(1, value.location.x / geo.size.width))
                            dragProgress = newProgress
                        }
                        .onEnded { value in
                            let newProgress = max(0, min(1, value.location.x / geo.size.width))
                            if let duration = viewModel.songDuration {
                                viewModel.seek(to: TimeInterval(newProgress) * duration)
                            }
                            dragProgress = nil
                        }
                )
            }
            .frame(height: 14)

            Text(formatTime(viewModel.songDuration ?? 0))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(AppColors.labelDim)
                .frame(width: 36, alignment: .leading)
        }
        .padding(.horizontal, 20)  // HIG: consistent 20pt edge inset
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// ============================================================
// MARK: - V2 Waveform Visualizer
// ============================================================

/// Waveform bar yang lebih besar dan lebih visible. Bar putih saat recording,
/// abu-abu saat idle. Animasi spring ringan.
struct WaveformVisualizerViewV2: View {
    @ObservedObject var viewModel: RecordViewModel

    var body: some View {
        HStack(spacing: 3.0) {
            ForEach(0..<viewModel.audioLevels.count, id: \.self) { index in
                let level = viewModel.audioLevels[index]

                let smoothLevel = max(0, level - 0.05)
                let maxBarHeight: CGFloat = 100.0
                let barHeight: CGFloat = min(maxBarHeight, max(2, smoothLevel * 100.0))

                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white)
                    .frame(width: 3.0, height: barHeight)
                    .animation(.easeOut(duration: 0.15), value: barHeight)
            }
        }
        .frame(height: 80.0)
    }
}

// ============================================================
// MARK: - V2 Record Controls (Replay + Mic/Pause)
// ============================================================

/// Bottom control bar menggunakan glassEffect (iOS 26+).
struct RecordControlsViewV2: View {
    @ObservedObject var viewModel: RecordViewModel
    /// Dipanggil saat pengguna menekan tombol Pause (sedang merekam → berhenti)
    var onPause: () -> Void = {}

    var body: some View {
        ZStack {
            // ── Replay (Kiri) ──────────────────────────────────────────────
            HStack {
                Button(action: {
                    viewModel.replayRecording()
                }) {
                    Image(systemName: "arrow.trianglehead.clockwise")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 65, height: 65)
                }
                .glassEffect(.regular.interactive())
                .padding(.leading, 75)

                Spacer()
            }

            // ── Mic / Pause (Tengah) ─────────────────────────────────────────
            Button(action: {
                if viewModel.isPlaying {
                    // Tombol Pause ditekan saat sedang merekam → navigasi ke History
                    onPause()
                } else {
                    // Tombol Mic ditekan saat idle → mulai rekam
                    viewModel.togglePlayAndRecord()
                }
            }) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "mic")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 95, height: 95)
            }
            .glassEffect(.regular.interactive())
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }
}
