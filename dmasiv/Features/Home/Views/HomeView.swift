import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Users...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.loadUsers() }
                    }
                } else {
                    List(viewModel.users) { user in
                        UserRowView(user: user)
                    }
                    .refreshable {
                        await viewModel.loadUsers()
                    }
                }
            }
            .navigationTitle("Users")
            .task {
                if viewModel.users.isEmpty {
                    await viewModel.loadUsers()
                }
            }
        }
    }
}

// Separated Subview for cleaner code
struct UserRowView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(user.name)
                .font(.headline)
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
#endif
