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
        title: "Apalah (Arti Menunggu)",
        artist: "Raisa",
        duration: "3:34",
        audioFileName: "apalah-bgm",
        vocalistFileName: "apalah-midi",
        lyricFileName: "apalah-lrc",
        coverImageName: "cover_apalah"
    ),
    Song(
        id: UUID(),
        title: "Sempurna",
        artist: "Andra and The Backbone",
        duration: "4:25",
        audioFileName: "sempurna-bgm",
        vocalistFileName: "sempurna-midi",
        lyricFileName: "sempurna-lrc",
        coverImageName: "cover_sempurna"
    )
]
