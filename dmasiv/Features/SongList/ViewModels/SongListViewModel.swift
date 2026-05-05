import Foundation

class SongListViewModel: ObservableObject {
    @Published var songs: [Song] = [] // Asumsi SongLibrary sudah ada
    @Published var searchText: String = ""
    
    init() {
        self.songs = SongLibrary
    }
    
    // Logika Filter: Hanya lagu yang diawali dengan huruf yang diketik
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { song in
                song.title.lowercased().hasPrefix(searchText.lowercased())
            }
        }
    }
}
