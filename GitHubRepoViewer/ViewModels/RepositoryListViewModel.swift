import Foundation

@MainActor
class RepositoryListViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var lastSearchedUsername = ""
    @Published var lastFetchTime: Date?
    
    private let gitHubService: GitHubServiceProtocol
    
    init(gitHubService: GitHubServiceProtocol = GitHubService()) {
        self.gitHubService = gitHubService
    }
    
    func searchRepositories() async {
        let trimmedUsername = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUsername.isEmpty else {
            errorMessage = "Please enter a username"
            return
        }
        
        print("🔍 Starting search for user: \(trimmedUsername)")
        
        lastSearchedUsername = trimmedUsername
        isLoading = true
        errorMessage = nil
        
        // Clear previous results to show fresh loading
        repositories = []
        
        await performFetch(for: trimmedUsername, isRefresh: false)
    }
    
    func refreshRepositories() async {
        // Only refresh if we have a previous search
        guard !lastSearchedUsername.isEmpty else {
            print("⚠️ No previous search to refresh")
            return
        }
        
        print("🔄 Refreshing repositories for user: \(lastSearchedUsername)")
        
        errorMessage = nil
        await performFetch(for: lastSearchedUsername, isRefresh: true)
    }
    
    private func performFetch(for username: String, isRefresh: Bool) async {
        do {
            let fetchedRepositories = try await gitHubService.fetchRepositories(for: username)
            
            // Always update with fresh data
            repositories = fetchedRepositories
            lastFetchTime = Date()
            
            if repositories.isEmpty {
                errorMessage = "No repositories found for this user"
            } else {
                errorMessage = nil
                print("✅ Successfully loaded \(repositories.count) repositories")
            }
            
        } catch {
            print("❌ Error fetching repositories: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            
            // Only clear repositories if it's not a refresh
            if !isRefresh {
                repositories = []
            }
        }
        
        if !isRefresh {
            isLoading = false
        }
    }
    
    func clearData() {
        repositories = []
        errorMessage = nil
        lastSearchedUsername = ""
        lastFetchTime = nil
        print("🧹 Cleared all data")
    }
}
