import SwiftUI

struct SongCard: View {
    let song: Song
    
    var body: some View {
        HStack(spacing: 16) {
            // Foto Album
            if let coverName = song.coverImageName {
                Image(coverName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                // Fallback jika tidak ada cover image
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )
            }
            
            // informasi lagu
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(song.duration)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
    }
}
