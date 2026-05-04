import SwiftUI

struct SongListView: View {
    @StateObject private var viewModel = SongListViewModel()

    // Stub song for navigation demo
    private let stubSong = Song.Januari

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: RecordView(song: stubSong)) {
                    VStack(alignment: .leading) {
                        HStack {
//                            Image("cover_januari")
//                                .frame(width: 2, height: 2)
                            
                            VStack {
                                Text(stubSong.title)
                                    .font(.headline)
                                Text(stubSong.artist)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "clock")
                                    
                                    Text(stubSong.duration)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            
            TabView {
                Text("")
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                Text("")
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    }
            }
        }
    }
}

#Preview {
    SongListView()
}
