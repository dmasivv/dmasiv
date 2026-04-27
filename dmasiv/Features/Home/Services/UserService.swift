import Foundation

protocol UserServiceProtocol {
    func fetchUsers() async throws -> [User]
}

class UserService: UserServiceProtocol {
    private let apiClient: APIClientProtocol
    
    // Dependency Injection allows for easy mocking in tests
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            throw NetworkingError.invalidURL
        }
        return try await apiClient.execute(URLRequest(url: url))
    }
}
