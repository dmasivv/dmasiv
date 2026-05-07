import SwiftUI

// ============================================================
// MARK: - V2 Lyric Card
// ============================================================

/// Glass card yang menampilkan lirik: 3 baris lalu + aktif + 4 upcoming.
struct LyricCardViewV2: View {
    @ObservedObject var viewModel: RecordViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Ruang kosong atas agar lirik pertama bisa ke tengah
                    Color.clear.frame(height: 60)

                    ForEach(Array(viewModel.allLyrics.enumerated()), id: \.element.id) { index, lyric in
                        let isCurrent = index == viewModel.currentLyricIndex
                        let progress  = progressFor(index: index)

                        LyricRowWithBarView(lyric: lyric, isCurrent: isCurrent, progress: progress)
                            .id(index) // ID untuk target scroll
                    }

                    // Ruang kosong bawah
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(
                ZStack {
                    // Fill utama
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(white: 0.1).opacity(0.3))

                    // Border luar: gradient biru-abu dari atas ke bawah
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color(red: 0.18, green: 0.22, blue: 0.38).opacity(0.6),
                                    Color(red: 0.12, green: 0.15, blue: 0.28).opacity(0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )

                    // Inner glow halus
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.06), lineWidth: 4)
                        .blur(radius: 3)
                        .mask(RoundedRectangle(cornerRadius: 24))
                }
            )
            .onChange(of: viewModel.currentLyricIndex) { newIndex in
                if let idx = newIndex {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        proxy.scrollTo(idx, anchor: .center)
                    }
                }
            }
            .onAppear {
                if let idx = viewModel.currentLyricIndex {
                    proxy.scrollTo(idx, anchor: .center)
                }
            }
        }
        .padding(.horizontal, 35)  // HIG: consistent edge inset
        .padding(.top, 12)
    }

    private func progressFor(index: Int) -> CGFloat {
        let lyric    = viewModel.allLyrics[index]
        let duration = lyric.endTime - lyric.startTime
        guard duration > 0 else { return 1.0 }
        let p = (viewModel.currentTime - lyric.startTime) / duration
        return CGFloat(min(max(p, 0), 1))
    }
}

/// Satu baris lirik. Bar napas HANYA muncul untuk baris "BREATHE".
/// HIG: font size ≥ 22pt untuk readability, consistent spacing.
struct LyricRowWithBarView: View {
    let lyric: LyricLine
    let isCurrent: Bool
    let progress: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if lyric.isBreathe {
                // ── Baris BREATHE: bar napas animasi ─────────────────
                BreathBarIndicatorView(
                    progress: isCurrent ? progress : 1.0,
                    isCurrent: isCurrent
                )
            } else if lyric.text.isEmpty {
                // ── Jeda instrumental: tiga titik ────────────────────
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(AppColors.lyricActive.opacity(isCurrent ? 0.3 : 0.12))
                            .frame(width: 5, height: 5)
                    }
                }
            } else {
                // ── Baris lirik normal (Highlight Full) ──────────────────
                Text(lyric.text)
                    .font(.system(
                        size: isCurrent ? 30 : 26,
                        weight: isCurrent ? .bold : .regular,
                        design: .rounded
                    ))
                    .foregroundColor(isCurrent ? .white : .white.opacity(0.40))
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .animation(.easeInOut(duration: 0.2), value: isCurrent)
            }
        }
        .padding(.vertical, 10)
    }
}

/// Bar kecil biru di bawah tiap baris lirik — indikator jeda napas.
/// Lebar FIXED (bukan full-width), sesuai referensi:
/// - Non-aktif: track 64pt, fill 64pt (solid dim)
/// - Aktif: track 160pt, fill animasi sesuai progress
struct BreathBarIndicatorView: View {
    let progress: CGFloat
    let isCurrent: Bool

    // Lebar track background (referensi: aktif ~160pt, non-aktif ~64pt)
    private var trackWidth: CGFloat { isCurrent ? 160 : 64 }
    // Lebar fill minimum 8pt agar selalu ada sedikit warna biru
    private var fillWidth: CGFloat {
        isCurrent ? max(8, trackWidth * progress) : trackWidth
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Track background
            RoundedRectangle(cornerRadius: 3)
                .fill(AppColors.overlayLight)
                .frame(width: trackWidth, height: 5)

            // Fill biru ke putih sesuai referensi gambar
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    isCurrent
                    ? LinearGradient(
                        colors: [AppColors.accentBlue,                     // Biru kuat di kiri
                                 AppColors.lyricActive],                    // Memutih di kanan
                        startPoint: .leading,
                        endPoint: .trailing
                      )
                    : LinearGradient(
                        colors: [AppColors.accentBlueSoft.opacity(0.55),
                                 AppColors.accentBlueSoft.opacity(0.55)],
                        startPoint: .leading,
                        endPoint: .trailing
                      )
                )
                .frame(width: fillWidth, height: 5)
                .shadow(color: .black.opacity(isCurrent ? 0.3 : 0.0), radius: 2, x: 0, y: 1)
                .animation(.linear(duration: 0.06), value: progress)
        }
        .frame(height: 5, alignment: .leading)
    }
}
