import SwiftUI

struct RecordingRow: View {
    let recording: RecordingItem
    let action: () -> Void

    private var matchedSong: Song? {
        let name = recording.name
        // File format: "Song Title [N]" — strip trailing " [<digits>]"
        let title: String
        if let range = name.range(of: #" \[\d+\]$"#, options: .regularExpression) {
            title = String(name[..<range.lowerBound])
        } else {
            title = name
        }
        return SongLibrary.first { $0.title == title }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                albumCover

                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text(matchedSong?.artist ?? "Unknown Artist")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.55, green: 0.60, blue: 0.72))
                        .lineLimit(1)

                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(recording.formattedDuration)
                            .font(.system(size: 12))
                        Text("·")
                            .font(.system(size: 12))
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(recording.shortFormattedDate)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.62))
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var albumCover: some View {
        if let coverName = matchedSong?.coverImageName {
            Image(coverName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 65, height: 65)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    colors: [AppColors.albumArtTop, AppColors.albumArtBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 65, height: 65)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 65 * 0.3))
                        .foregroundColor(.white.opacity(0.4))
                )
        }
    }
}
