import SwiftUI

// ============================================================
// MARK: - V2 Breath Timeline
// ============================================================

/// Timeline berjalan yang menunjukkan kapan harus bernapas.
/// Lingkaran kecil = curi napas, kapsul panjang = napas panjang.
struct BreathTimelineView: View {
    @ObservedObject var viewModel: RecordViewModel

    var body: some View {
        GeometryReader { geo in
            let playheadX: CGFloat = 35 // Posisi garis playhead di kiri
            let visibleDuration: TimeInterval = 4.0 // Berapa detik ke depan yang terlihat
            let pixelsPerSecond = (geo.size.width - playheadX) / CGFloat(visibleDuration)
            let trackHeight = geo.size.height

            // Cek apakah saat ini playhead sedang mengenai marker napas
            let isInhaling = viewModel.breathMarkers.contains { marker in
                viewModel.currentTime >= marker.startTime && viewModel.currentTime <= marker.endTime
            }

            ZStack(alignment: .leading) {
                // Background Track (Kaca gelap)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )

                // 3 Garis Horizontal (Track lanes)
                VStack(spacing: 0) {
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                    Spacer()
                }

                // Exhale Markers (Lirik yang dinyanyikan - Liquid Glass Abu-abu)
                ForEach(viewModel.allLyrics) { marker in
                    let timeDiff = marker.startTime - viewModel.currentTime
                    let xPos = playheadX + CGFloat(timeDiff) * pixelsPerSecond
                    let duration = marker.endTime - marker.startTime
                    let width = max(16.0, CGFloat(duration) * pixelsPerSecond)

                    if (xPos + width) > -50 && xPos < geo.size.width + 100 {
                        // Efek Liquid Glass: transparan dengan border tipis
                        Capsule()
                            .fill(Color.white.opacity(0.01))
                            .background(Capsule().fill(.ultraThinMaterial))
                            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                            .frame(width: width, height: 18)
                            .position(x: xPos + (width / 2), y: trackHeight / 2)
                    }
                }

                // Inhale Markers (Ambil Napas - Biru Solid)
                ForEach(viewModel.breathMarkers) { marker in
                    let timeDiff = marker.startTime - viewModel.currentTime
                    let xPos = playheadX + CGFloat(timeDiff) * pixelsPerSecond
                    let duration = marker.endTime - marker.startTime
                    let width = max(16.0, CGFloat(duration) * pixelsPerSecond)

                    if (xPos + width) > -50 && xPos < geo.size.width + 100 {
                        Capsule()
                            .fill(Color(red: 0.22, green: 0.41, blue: 0.85)) // Biru solid
                            .frame(width: width, height: 18)
                            .position(x: xPos + (width / 2), y: trackHeight / 2)
                    }
                }

                // Garis Vertikal Playhead
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 1, height: trackHeight)
                    .position(x: playheadX, y: trackHeight / 2)

                // Lingkaran Playhead / Tulisan INHALE
                ZStack {
                    if isInhaling {
                        Text("INHALE")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 0.22, green: 0.41, blue: 0.85))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                .frame(width: 24, height: 24)
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 16, height: 16)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                // Geser menyesuaikan lebar tulisan agar tidak memotong batas kiri
                .position(x: isInhaling ? playheadX + 24 : playheadX, y: trackHeight / 2)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isInhaling)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(height: 60)
    }
}
