import SwiftUI

struct SongListView: View {
    @StateObject private var viewModel = SongListViewModel()
    
    @State private var selectedTab = 0
    @State private var isSearchActive = false

    var body: some View {
        ZStack(alignment: .bottom) {
            
            TabView(selection: $selectedTab) {
                HomeTabView(viewModel: viewModel)
                    .tag(0)
                    .toolbar(.hidden, for: .tabBar)
                
                HistoryTabView()
                    .tag(1)
                    .toolbar(.hidden, for: .tabBar)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            DynamicTabBarView(
                viewModel: viewModel,
                selectedTab: $selectedTab,
                isSearchActive: $isSearchActive
            )
            .padding(.bottom, 16)
        }
    }
}

struct HomeTabView: View {
    @ObservedObject var viewModel: SongListViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                List(viewModel.filteredSongs) { song in
                    NavigationLink(destination: RecordView(song: song).toolbar(.hidden, for: .tabBar)) {
                        SongCard(song: song)
                    }
                    .cardStyleRow()
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .safeAreaPadding(.bottom, 100)
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView().toolbar(.hidden, for: .tabBar)) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

struct HistoryTabView: View {
    var body: some View {
        NavigationStack {
            HistoryView()
                .safeAreaPadding(.bottom, 100)
        }
    }
}

struct DynamicTabBarView: View {
    @ObservedObject var viewModel: SongListViewModel
    @Binding var selectedTab: Int
    @Binding var isSearchActive: Bool
    
    @FocusState private var isInputFocused: Bool

    var body: some View {
        HStack {
            if !isSearchActive {
                HStack(spacing: 0) {
                    TabButtonView(title: "Home", icon: "house.fill", tabIndex: 0, selectedTab: $selectedTab)
                    TabButtonView(title: "History", icon: "clock.arrow.circlepath", tabIndex: 1, selectedTab: $selectedTab)
                    
                    // Tombol Search
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            selectedTab = 0
                            isSearchActive = true
                            isInputFocused = true
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                        }
                        .foregroundColor(.black)
                        .frame(width: 80, height: 60)
                        .background(Color.clear)
                    }
                }
                
            } else {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isSearchActive = false
                            viewModel.searchText = ""
                            isInputFocused = false
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.blue)
                    }
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search lagu...", text: $viewModel.searchText)
                        .focused($isInputFocused)
                        .disableAutocorrection(true)
                        .submitLabel(.search)
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(6)
        .frame(height: 72)
        .background(Color.white, in: Capsule())
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, isSearchActive ? 24 : 0)
    }
}

struct TabButtonView: View {
    let title: String
    let icon: String
    let tabIndex: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tabIndex
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(selectedTab == tabIndex ? .blue : .black)
            .frame(width: 80, height: 60)
            .background(
                Capsule()
                    .fill(selectedTab == tabIndex ? Color(UIColor.systemGray5) : Color.clear)
            )
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
