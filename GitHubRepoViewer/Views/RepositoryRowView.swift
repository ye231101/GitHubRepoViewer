import SwiftUI

struct RepositoryRowView: View {
    let repository: Repository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(repository.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(repository.stargazersCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let description = repository.description {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RepositoryRowView(repository: Repository(
        id: 1,
        name: "awesome-repo",
        description: "This is an awesome repository for demonstration purposes",
        stargazersCount: 42,
        htmlUrl: "https://github.com/user/awesome-repo"
    ))
    .padding()
}
