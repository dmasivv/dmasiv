import Foundation
import SwiftUI

@MainActor
class PlayerViewModel: ObservableObject {
    @Published private(set) var currentSong: Song?
    @Published private(set) var lyrics: [LyricLine] = []
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var isPlaying: Bool = false
    
    let audioService: AudioPlayerServiceProtocol
    
    init(audioService: AudioPlayerServiceProtocol = AudioPlayerService()) {
        self.audioService = audioService
    }
    
    // Stubs for player controls
    func togglePlayPause() {}
    func loadSong(_ song: Song) {}
}
