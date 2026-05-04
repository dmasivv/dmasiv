import Foundation

// Represents an offline song available in the app bundle
struct Song: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let duration: String // durasi lagu
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
        duration: "3:47",
        audioFileName: "januari-bgm",
        vocalistFileName: "januari-midi",
        lyricFileName: "januari-lrc",
        coverImageName: "cover_januari"
    )
}

let SongLibrary : [Song] = [
    Song(
        id: UUID(),
        title: "Januari",
        artist: "Glenn Fredly",
        duration: "3:47",
        audioFileName: "januari-bgm",
        vocalistFileName: "januari-midi",
        lyricFileName: "januari-lrc",
        coverImageName: "cover_januari"
    ),
    Song(
        id: UUID(),
        title: "Versace On The Floor",
        artist: "Bruno Mars",
        duration: "3:47",
        audioFileName: "versaceOnTheFloor-bgm",
        vocalistFileName: "versaceOnTheFloor-midi",
        lyricFileName: "versaceOnTheFloor-lrc",
        coverImageName: "cover_versaceOnTheFloor"
    )
]
