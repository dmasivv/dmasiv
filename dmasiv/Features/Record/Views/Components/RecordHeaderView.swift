import SwiftUI

// ============================================================
// MARK: - V2 Header with Album Art
// ============================================================

/// Header: album art (kiri) + judul & artis (kanan).
/// HIG: minimum 44pt tap target, SF Rounded for consistency, 20pt edge insets.
struct RecordHeaderViewV2: View {
    let song: Song

    var body: some View {
        HStack(spacing: 16) {
            // Album art atau placeholder — 100×100 (HIG: prominent media)
            Group {
                if let imageName = song.coverImageName,
                   let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.albumArtTop,
                                             AppColors.albumArtBottom],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Image(systemName: "music.note")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(AppColors.lyricActive.opacity(0.8))
                    }
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 5) {
                Text(song.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.lyricActive)
                Text(song.artist)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.lyricSubtitle)
            }
            Spacer()
        }
        .padding(.horizontal, 35)  // HIG: consistent 30pt edge inset
        .padding(.top, 15)
    }
}
