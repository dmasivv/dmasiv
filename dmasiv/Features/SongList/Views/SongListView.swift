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

struct CardStyleRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
            .listRowBackground(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            )
    }
}

extension View {
    func cardStyleRow() -> some View {
        self.modifier(CardStyleRowModifier())
    }
}

#Preview {
    SongListView()
}
