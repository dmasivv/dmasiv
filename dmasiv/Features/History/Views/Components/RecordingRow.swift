import SwiftUI

struct RecordingRow: View {
    let recording: RecordingItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Ikon Musik Kiri
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            colors: [Color(red: 0.22, green: 0.28, blue: 0.50), Color(red: 0.16, green: 0.20, blue: 0.38)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)

                    Image(systemName: "music.mic")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 20))
                }

                // Teks Informasi
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack {
                        Text(recording.formattedDate)
                        Text("•")
                        Text(recording.formattedSize)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.62))
                }

                Spacer()

                // Ikon Play
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
