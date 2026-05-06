import SwiftUI

struct SongCard: View {
    let song: Song
    let isExpanded: Bool
    let onToggle: () -> Void
    let onPlay: () -> Void

    // ── Warna persis dari referensi ──────────────────────────────────────
    private let cardFill = Color(red: 0.12, green: 0.16, blue: 0.28)
    private let cardBorder = Color(red: 0.20, green: 0.25, blue: 0.40)
    private let chevronBg = Color(red: 0.18, green: 0.22, blue: 0.36)

    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                expandedContent
            } else {
                collapsedContent
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(cardBorder, lineWidth: 0.8)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Collapsed ──────────────────────────────────────────────────

    private var collapsedContent: some View {
        HStack(spacing: 14) {
            albumCover(size: 65)

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(song.artist)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.55, green: 0.60, blue: 0.72))
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(song.duration)
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.62))
            }

            Spacer()

            chevronCircle(isUp: false)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
    }

    // MARK: - Expanded ───────────────────────────────────────────────────

    private var expandedContent: some View {
        VStack(spacing: 8) {
            // Chevron (top-right)
            HStack {
                Spacer()
                chevronCircle(isUp: true)
                    .onTapGesture { onToggle() }
            }
            .padding(.top, 14)
            .padding(.trailing, 14)

            // Large album art
            albumCover(size: 200)
                .shadow(color: .black.opacity(0.45), radius: 16, x: 0, y: 8)

            // Title
            Text(song.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            // Artist
            Text(song.artist)
                .font(.system(size: 15))
                .foregroundColor(Color(red: 0.55, green: 0.60, blue: 0.72))

            // Duration
            HStack(spacing: 5) {
                Image(systemName: "clock")
                    .font(.system(size: 13))
                Text(song.duration)
                    .font(.system(size: 14))
            }
            .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.62))

            // Tags (Key & BPM)
            if song.key != nil || song.bpm != nil {
                HStack(spacing: 10) {
                    if let key = song.key { tagPill(key) }
                    if let bpm = song.bpm { tagPill("\(bpm) BPM") }
                }
                .padding(.top, 4)
            }

            // Action buttons
            GlassEffectContainer(spacing: 14) {
                HStack(spacing: 14) {
                    Button(action: onPlay) {
                        Text("Play")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .padding(.horizontal, 20)
                    }
                    .glassEffect(.regular.tint(.blue).interactive())

                    Button(action: {}) {
                        Text("Edit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .padding(.horizontal, 20)
                    }
                    .glassEffect(.regular.interactive())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
    }

    // MARK: - Helpers ────────────────────────────────────────────────────

    @ViewBuilder
    private func albumCover(size: CGFloat) -> some View {
        let radius: CGFloat = size > 100 ? 14 : 10
        if let coverName = song.coverImageName {
            Image(coverName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: radius))
        } else {
            RoundedRectangle(cornerRadius: radius)
                .fill(LinearGradient(
                    colors: [AppColors.albumArtTop, AppColors.albumArtBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: size * 0.3))
                        .foregroundColor(.white.opacity(0.4))
                )
        }
    }

    private func chevronCircle(isUp: Bool) -> some View {
        Image(systemName: isUp ? "chevron.up" : "chevron.down")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 34, height: 34)
            .glassEffect(.regular.interactive())
    }

    private func tagPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Color(red: 0.55, green: 0.60, blue: 0.72))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().stroke(cardBorder, lineWidth: 1))
    }
}
