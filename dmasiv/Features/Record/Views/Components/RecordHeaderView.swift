import SwiftUI

// ============================================================
// MARK: - V2 Header with Album Art
// ============================================================

/// Header: album art (kiri) + judul & artis (kanan).
/// HIG: minimum 44pt tap target, SF Rounded for consistency, 20pt edge insets.
    struct RecordHeaderViewV2: View {
        let song: Song
        @Environment(\.dismiss) var dismiss

        var body: some View {
            ZStack {
                // Tombol Back di kiri
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                    .glassEffect(.regular.interactive())
                    Spacer()
                }

                // Judul dan Artis di tengah
                VStack(spacing: 4) {
                    Text(song.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.lyricActive)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(song.artist)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.lyricSubtitle)
                        .lineLimit(1)
                }
                .padding(.horizontal, 50) // Agar tidak menabrak tombol back
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
