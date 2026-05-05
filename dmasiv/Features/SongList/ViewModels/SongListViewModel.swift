import Foundation
import SwiftUI

@MainActor
class SongListViewModel: ObservableObject {
    // The view will listen to this array
    @Published var songs: [Song] = []
    
    init() {
        fetchSongs()
    }
    
    // In the future, this could fetch from an API or CoreData.
    // For now, it just loads your local library.
    private func fetchSongs() {
        self.songs = SongLibrary
    }
}
