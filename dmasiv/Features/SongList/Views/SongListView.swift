import SwiftUI

struct SongListView: View {
    @StateObject private var viewModel = SongListViewModel()

    // Stub song for navigation demo
    private let stubSong = Song(
        id: UUID(),
        title: "Sample Song",
        artist: "Sample Artist",
        audioFileName: "sample.mp3",
        vocalistFileName: "sample.mid",
        lyricFileName: "sample.lrc",
        coverImageName: nil
    )

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: RecordView(song: stubSong)) {
                    VStack(alignment: .leading) {
                        Text(stubSong.title)
                            .font(.headline)
                        Text(stubSong.artist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Song List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}
