import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RepositoryListViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Search Section
                VStack(spacing: 12) {
                    TextField("Enter GitHub username", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            Task {
                                await viewModel.searchRepositories()
                            }
                        }
                    
                    HStack(spacing: 12) {
                        Button("Search Repositories") {
                            Task {
                                await viewModel.searchRepositories()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading)
                        
                        if !viewModel.repositories.isEmpty {
                            Button("Clear") {
                                viewModel.clearData()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Last Fetch Time Display
                if let lastFetchTime = viewModel.lastFetchTime {
                    Text("Last updated: \(lastFetchTime, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Content Section
                if viewModel.isLoading {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView("Fetching fresh data...")
                        Text("Getting latest repositories from GitHub")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        // Add retry button for errors
                        if !viewModel.lastSearchedUsername.isEmpty {
                            Button("Try Again") {
                                Task {
                                    await viewModel.refreshRepositories()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    Spacer()
                } else if !viewModel.repositories.isEmpty {
                    // Repository List with Pull-to-Refresh
                    List {
                        // Header showing current user and repo count
                        Section {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Repositories for: \(viewModel.lastSearchedUsername)")
                                    .font(.headline)
                                Text("\(viewModel.repositories.count) repositories found")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Repository rows
                        ForEach(viewModel.repositories) { repository in
                            RepositoryRowView(repository: repository)
                        }
                    }
                    .refreshable {
                        print("🔄 Pull-to-refresh triggered")
                        await viewModel.refreshRepositories()
                    }
                } else {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Enter a GitHub username to search for repositories")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Text("Pull down to refresh after searching")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                }
            }
            .navigationTitle("GitHub Repos")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView()
}
