import Foundation

enum GitHubError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .userNotFound:
            return "User not found"
        }
    }
}

protocol GitHubServiceProtocol {
    func fetchRepositories(for username: String) async throws -> [Repository]
}

class GitHubService: GitHubServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        // Configure URLSession to always fetch fresh data
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        self.session = URLSession(configuration: config)
    }
    
    func fetchRepositories(for username: String) async throws -> [Repository] {
        guard let url = URL(string: "https://api.github.com/users/\(username)/repos") else {
            throw GitHubError.invalidURL
        }
        
        // Create request with cache-busting headers
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        
        // Add timestamp to ensure fresh requests
        let timestamp = Date().timeIntervalSince1970
        let urlWithTimestamp = URL(string: "\(url.absoluteString)?_t=\(timestamp)")!
        request.url = urlWithTimestamp
        
        print("🌐 Fetching fresh data for user: \(username) at \(Date())")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 404 {
                    throw GitHubError.userNotFound
                }
            }
            
            let repositories = try JSONDecoder().decode([Repository].self, from: data)
            let sortedRepos = repositories.sorted { $0.stargazersCount > $1.stargazersCount }
            
            print("✅ Successfully fetched \(sortedRepos.count) repositories")
            return sortedRepos
            
        } catch let error as GitHubError {
            print("❌ GitHub API Error: \(error.localizedDescription)")
            throw error
        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")
            throw GitHubError.decodingError
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw GitHubError.networkError(error)
        }
    }
}
