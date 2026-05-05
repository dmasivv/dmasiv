import SwiftUI

struct RecordingRow: View {
    let recording: RecordingItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Ikon Musik Kiri
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: "music.mic")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }

                // Teks Informasi
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack {
                        Text(recording.formattedDate)
                        Text("•")
                        Text(recording.formattedSize)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()

                // Ikon Play
                Image(systemName: "play.circle")
                    .font(.title3)
                    .foregroundColor(.blue.opacity(0.8))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
