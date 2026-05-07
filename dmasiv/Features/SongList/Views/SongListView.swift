import SwiftUI

struct SongListView: View {
    @StateObject private var viewModel = SongListViewModel()
    @State private var expandedSongID: UUID? = nil
    @State private var navigateToSong: Song? = nil

    // Sinyal navigasi antar-tab
    @State private var selectedTab: Int = 0
    @State private var shouldAutoPlayNewest: Bool = false

    private let bgColor = Color(red: 0.04, green: 0.06, blue: 0.14)

    var body: some View {
        TabView(selection: $selectedTab) {
            homeTab
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
                .toolbarBackground(Color(red: 0.06, green: 0.08, blue: 0.18), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)

            historyTab
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                .tag(1)
                .toolbarBackground(Color(red: 0.06, green: 0.08, blue: 0.18), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
        }
        .tint(Color(red: 0.0, green: 0.85, blue: 0.85))
        .onAppear { configureTabBarAppearance() }
    }

    private func configureTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.18, alpha: 1)
        
        // Memaksa item tersebar penuh dari kiri ke kanan
//        UITabBar.appearance().itemPositioning = .fill
//        
//        UITabBar.appearance().standardAppearance = tabBarAppearance
//        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

extension SongListView {

    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Judul "Library" kustom — tanpa navigation bar bawaan ──
                    Text("Library")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 16)

                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.songs) { song in
                            SongCard(
                                song: song,
                                isExpanded: expandedSongID == song.id,
                                onToggle: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        expandedSongID = (expandedSongID == song.id) ? nil : song.id
                                    }
                                },
                                onPlay: {
                                    navigateToSong = song
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(bgColor.ignoresSafeArea())
            // Sembunyikan nav bar sistem agar tidak ada ruang kosong di atas
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .navigationDestination(item: $navigateToSong) { song in
                RecordView(
                    song: song,
                    selectedTab: $selectedTab,
                    shouldAutoPlayNewest: $shouldAutoPlayNewest
                )
                .toolbar(.hidden, for: .tabBar)
            }
        }
    }

    private var historyTab: some View {
        NavigationStack {
            HistoryView(shouldAutoPlayNewest: $shouldAutoPlayNewest)
        }
    }
}

#Preview {
    SongListView()
}
