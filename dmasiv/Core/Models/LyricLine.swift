import Foundation

// Represents a single line of lyric with its timestamp
struct LyricLine: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: TimeInterval // seconds from the start of the song
}
