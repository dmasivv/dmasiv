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

                let smoothLevel = max(0, level - 0.05) // Sedikit noise gate (opsional)
                let barHeight: CGFloat = max(2.0, smoothLevel * 100.0)

                RoundedRectangle(cornerRadius: 2.5)
                    .fill(
                        viewModel.isRecording
                        ? AppColors.waveformActive
                        : AppColors.waveformIdle
                    )
                    .frame(width: 3.0, height: barHeight)
                    .animation(.easeOut(duration: 0.15), value: barHeight)
            }
        }
        .frame(height: 100.0)
    }
}

// ============================================================
// MARK: - V2 Record Controls (Replay + Mic/Pause)
// ============================================================

/// Bottom control bar — HIG: min 44pt tap targets, primary action centered.
/// - Mic/Pause: centered di tengah layar secara horizontal
/// - Replay: di kiri tombol Mic
struct RecordControlsViewV2: View {
    @ObservedObject var viewModel: RecordViewModel
    @Binding var navigateToResult: Bool

    var body: some View {
        ZStack {
            // ── Mic / Stop (centered horizontal) ────────────────────────
            Button(action: {
                if viewModel.isPlaying {
                    // Jika lagu sedang berjalan, Stop rekaman
                    viewModel.stopRecording()
                    // Ubah state binding untuk exit ke HistoryView / Result page
                    navigateToResult = true
                } else {
                    // Jika belum berjalan, Start rekaman
                    viewModel.startRecording()
                }
            }) {
                ZStack {
                    // Background gradasi dalam tombol
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.buttonBlueTop,
                                         AppColors.buttonBlueBottom],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)

                    // Outer ring tebal solid putih
                    Circle()
                        .stroke(AppColors.lyricActive, lineWidth: 4.5)
                        .frame(width: 90, height: 90)

                    // Icon putih tebal tanpa fill background
                    // Ganti icon menjadi "stop.fill" (kotak) agar user tahu ini tombol stop, bukan pause
                    Image(systemName: viewModel.isPlaying ? "stop.fill" : "mic.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(AppColors.lyricActive)
                }
            }

            // ── Replay (kiri dari mic) ────────────────────────────────────
            HStack {
                Button(action: {
                    viewModel.replayRecording()
                }) {
                    ZStack {
                        // Background gradasi dalam tombol
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.buttonBlueTop,
                                             AppColors.buttonBlueBottom],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)

                        // Border tipis solid putih
                        Circle()
                            .stroke(AppColors.lyricActive, lineWidth: 1.2)
                            .frame(width: 52, height: 52)

                        // Icon arrow tebal solid putih
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppColors.lyricActive)
                    }
                }
                .padding(.leading, 75)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
