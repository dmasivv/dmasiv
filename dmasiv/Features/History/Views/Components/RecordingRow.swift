import SwiftUI

struct RecordingRow: View {
    let recording: RecordingItem
    let action: () -> Void
    
    // Warna persis dari referensi SongCard
    private let cardFill = Color(red: 0.12, green: 0.16, blue: 0.28)
    private let cardBorder = Color(red: 0.20, green: 0.25, blue: 0.40)
    private let menuBg = Color(red: 0.18, green: 0.22, blue: 0.36)
    
    // Mendapatkan data lagu asli dari library jika namanya cocok
    private var matchedSong: Song? {
        let baseName = recording.name.components(separatedBy: " [").first ?? recording.name
        return SongLibrary.first { $0.title.lowercased() == baseName.lowercased() }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Ikon Musik Kiri (Album Cover)
                if let song = matchedSong, let cover = song.coverImageName {
                    Image(cover)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 65, height: 65)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 65, height: 65)
                        
                        Image(systemName: "music.mic")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 24))
                    }
                }
                
                // Teks Informasi
                VStack(alignment: .leading, spacing: 4) {
                    Text(matchedSong?.title ?? recording.name)
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
                        Text(recording.formattedDate)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.62))
                }
                
                Spacer()
                
                // Ikon Menu (Hamburger)
                ZStack {
                    Circle()
                        .fill(menuBg)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
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
        .buttonStyle(.plain)
    }
}
