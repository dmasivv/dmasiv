import SwiftUI

struct SongListView: View {
    @StateObject private var viewModel = SongListViewModel()

    var body: some View {
        TabView {
            homeTab
                .tabItem { Label("Home", systemImage: "house") }
            
            historyTab
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
    }
}

extension SongListView {
    
    private var homeTab: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                List(viewModel.songs) { song in
                    NavigationLink(destination: RecordView(song: song).toolbar(.hidden, for: .tabBar)) {
                        SongCard(song: song)
                    }
                    .cardStyleRow()
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Library")
            .toolbar { settingsButton }
        }
    }
    
    private var historyTab: some View {
        NavigationStack {
            HistoryView()
        }
    }
    
    private var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: SettingsView().toolbar(.hidden, for: .tabBar)) {
                Image(systemName: "gear")
            }
        }
    }
}

#Preview {
    SongListView()
}
