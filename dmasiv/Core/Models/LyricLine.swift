import Foundation

// Represents a single line of lyric with its start and end timestamp
struct LyricLine: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let startTime: TimeInterval // seconds from the start of the song
    var endTime: TimeInterval   // when this lyric line ends (next lyric start - 0.1, or +4s for last)
}
