import Foundation

struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case stargazersCount = "stargazers_count"
        case htmlUrl = "html_url"
    }
}
