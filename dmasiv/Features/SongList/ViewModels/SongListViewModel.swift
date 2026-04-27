import Foundation
import SwiftUI

@MainActor
class SongListViewModel: ObservableObject {
    @Published private(set) var availableSongs: [Song] = []
    
    // Method to load local songs from Resources
    func loadLocalSongs() {
        // To do: Load hardcoded songs or scan local bundle
    }
}
