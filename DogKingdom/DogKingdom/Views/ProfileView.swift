import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var leaderboard: [AppUser] = []
    @State private var isLoadingLeaderboard = false

    var body: some View {
        NavigationView {
            List {
                // User info section
                if let user = authViewModel.currentUser {
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                if let email = user.email {
                                    Text(email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Text("Member since \(user.createdAt, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Stats section
                    Section("Your Stats") {
                        StatRow(
                            icon: "flag.fill",
                            title: "Territories Claimed",
                            value: "\(user.territoriesCount)"
                        )

                        StatRow(
                            icon: "square.fill",
                            title: "Total Area",
                            value: formatArea(user.totalAreaClaimed)
                        )
                    }
                }

                // Leaderboard section
                Section("Leaderboard") {
                    if isLoadingLeaderboard {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if leaderboard.isEmpty {
                        Text("No players yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, user in
                            LeaderboardRow(
                                rank: index + 1,
                                user: user,
                                isCurrentUser: user.id == authViewModel.currentUser?.id
                            )
                        }
                    }
                }

                // Settings section
                Section("Settings") {
                    Button {
                        // TODO: Implement notification settings
                    } label: {
                        Label("Notifications", systemImage: "bell.fill")
                    }

                    Button {
                        // TODO: Implement privacy settings
                    } label: {
                        Label("Privacy", systemImage: "lock.fill")
                    }

                    Link(destination: URL(string: "https://example.com/help")!) {
                        Label("Help & Support", systemImage: "questionmark.circle.fill")
                    }
                }

                // Sign out
                Section {
                    Button(role: .destructive) {
                        authViewModel.signOut()
                        dismiss()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadLeaderboard()
            }
        }
    }

    private func loadLeaderboard() {
        isLoadingLeaderboard = true
        Task {
            do {
                let users = try await FirebaseService.shared.getLeaderboard()
                await MainActor.run {
                    self.leaderboard = users
                    self.isLoadingLeaderboard = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingLeaderboard = false
                }
            }
        }
    }

    private func formatArea(_ area: Double) -> String {
        if area >= 1_000_000 {
            return String(format: "%.2f km²", area / 1_000_000)
        } else {
            return String(format: "%.0f m²", area)
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let user: AppUser
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.headline)
                .foregroundColor(rankColor)
                .frame(width: 30)

            // Medal for top 3
            if rank <= 3 {
                Image(systemName: "medal.fill")
                    .foregroundColor(rankColor)
            }

            // User info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(user.displayName)
                        .fontWeight(isCurrentUser ? .bold : .regular)

                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Text("\(user.territoriesCount) territories")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Area
            Text(formatArea(user.totalAreaClaimed))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .background(isCurrentUser ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }

    private func formatArea(_ area: Double) -> String {
        if area >= 1_000_000 {
            return String(format: "%.1fkm²", area / 1_000_000)
        } else if area >= 1000 {
            return String(format: "%.1fk m²", area / 1000)
        } else {
            return String(format: "%.0fm²", area)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
