import Foundation

// Represents an offline song available in the app bundle
struct Song: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let audioFileName: String
    let lyricFileName: String
    let coverImageName: String?
}
