import Foundation

// Represents an offline song available in the app bundle
struct Song: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let audioFileName: String
    let vocalistFileName: String // Tambahan untuk file midi vocalist
    let lyricFileName: String
    let coverImageName: String?
}

extension Song {
    static let Januari = Song(
        id: UUID(),
        title: "Januari",
        artist: "Glenn Fredly",
        audioFileName: "januari-bgm",
        vocalistFileName: "januari-midi",
        lyricFileName: "januari-lrc",
        coverImageName: nil
    )
}
