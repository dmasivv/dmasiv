import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var users: [User] = [] // Read-only from view
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let userService: UserServiceProtocol
    
    // Dependency Injection
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        do {
            users = try await userService.fetchUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
