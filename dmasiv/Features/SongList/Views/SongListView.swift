import SwiftUI

struct SongListView: View {
    @StateObject private var viewModel = SongListViewModel()
    
    var body: some View {
        NavigationView {
            Text("Song List - Browse available offline songs here")
                .navigationTitle("Karaoke Songs")
        }
    }
}
