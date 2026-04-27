import Foundation

protocol APIClientProtocol {
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T
}

class APIClient: APIClientProtocol {
    static let shared = APIClient() // Singleton for basic usage
    
    private init() {}
    
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkingError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum NetworkingError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided is invalid."
        case .invalidResponse: return "The server response was invalid."
        case .decodingError: return "Failed to decode the response."
        }
    }
}
