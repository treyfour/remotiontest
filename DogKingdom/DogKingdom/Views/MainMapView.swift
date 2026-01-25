import SwiftUI
import MapKit

struct MainMapView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var locationViewModel = LocationViewModel()

    @State private var showingProfile = false
    @State private var showingClaimSuccess = false
    @State private var showingError = false
    @State private var showingTutorial = true

    var body: some View {
        ZStack {
            // Custom Map with polygon overlays
            TerritoryMapView(
                region: $mapViewModel.region,
                territories: mapViewModel.territories,
                currentUserId: authViewModel.currentUser?.id ?? "",
                pathCoordinates: locationViewModel.pathCoordinates,
                onTerritoryTapped: { territory in
                    mapViewModel.selectedTerritory = territory
                }
            )
            .edgesIgnoringSafeArea(.all)

            // UI Overlay
            VStack {
                // Top bar
                TopBarView(
                    userTerritoryCount: mapViewModel.userTerritoryCount,
                    totalArea: mapViewModel.totalUserArea,
                    onProfileTap: { showingProfile = true },
                    onCenterTap: {
                        if let location = locationViewModel.currentLocation {
                            mapViewModel.centerOnLocation(location)
                        }
                    }
                )

                Spacer()

                // Territory info card when selected
                if let territory = mapViewModel.selectedTerritory {
                    TerritoryInfoCard(
                        territory: territory,
                        isOwned: territory.ownerId == authViewModel.currentUser?.id,
                        onDismiss: { mapViewModel.selectedTerritory = nil }
                    )
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Bottom HUD
                ClaimingHUD(
                    locationViewModel: locationViewModel,
                    onClaimComplete: handleClaimComplete
                )
                .padding()
            }

            // Tutorial overlay for first-time users
            if showingTutorial {
                TutorialOverlay(onDismiss: { showingTutorial = false })
            }
        }
        .onAppear {
            setupViewModels()
            locationViewModel.requestLocationPermission()
            locationViewModel.startUpdatingLocation()
            mapViewModel.startListening()

            // Check if user has seen tutorial
            if UserDefaults.standard.bool(forKey: "hasSeenTutorial") {
                showingTutorial = false
            }
        }
        .onDisappear {
            mapViewModel.stopListening()
        }
        .onChange(of: locationViewModel.currentLocation) { location in
            if let location = location, mapViewModel.territories.isEmpty {
                mapViewModel.centerOnLocation(location)
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
        .alert("Territory Claimed!", isPresented: $showingClaimSuccess) {
            Button("OK") {
                locationViewModel.resetClaimingState()
            }
        } message: {
            Text("You've successfully claimed new territory! Check the map to see your land.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                mapViewModel.clearError()
            }
        } message: {
            Text(mapViewModel.errorMessage ?? "An error occurred")
        }
        .onChange(of: mapViewModel.errorMessage) { error in
            showingError = error != nil
        }
    }

    private func setupViewModels() {
        if let user = authViewModel.currentUser {
            locationViewModel.userId = user.id
            locationViewModel.userName = user.displayName
            mapViewModel.currentUserId = user.id
        }
    }

    private func handleClaimComplete(_ territory: Territory) {
        Task {
            let success = await mapViewModel.saveTerritory(territory)
            await MainActor.run {
                if success {
                    showingClaimSuccess = true
                }
                locationViewModel.resetClaimingState()
            }
        }
    }
}

// MARK: - Top Bar

struct TopBarView: View {
    let userTerritoryCount: Int
    let totalArea: Double
    let onProfileTap: () -> Void
    let onCenterTap: () -> Void

    var body: some View {
        HStack {
            // Profile button
            Button(action: onProfileTap) {
                HStack(spacing: 8) {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.title)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(userTerritoryCount)")
                            .font(.headline)
                        Text(formatArea(totalArea))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            .foregroundColor(.primary)

            Spacer()

            // Center on location button
            Button(action: onCenterTap) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding()
    }

    private func formatArea(_ area: Double) -> String {
        if area >= 10000 {
            return String(format: "%.1f ha", area / 10000)
        } else if area >= 1 {
            return String(format: "%.0f m²", area)
        } else {
            return "0 m²"
        }
    }
}

// MARK: - Tutorial Overlay

struct TutorialOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                // Dog mascot
                Image(systemName: "pawprint.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                Text("Welcome to Dog Kingdom!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 20) {
                    TutorialStep(
                        number: 1,
                        icon: "figure.walk",
                        text: "Tap 'Start Claiming' and walk in any closed shape"
                    )

                    TutorialStep(
                        number: 2,
                        icon: "arrow.triangle.turn.up.right.circle",
                        text: "Return to your starting point to close the loop"
                    )

                    TutorialStep(
                        number: 3,
                        icon: "flag.fill",
                        text: "Claim territory and see it on the map!"
                    )

                    TutorialStep(
                        number: 4,
                        icon: "scissors",
                        text: "Walk through others' territory to carve it away"
                    )
                }
                .padding()

                Button {
                    UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
                    onDismiss()
                } label: {
                    Text("Let's Go!")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
    }
}

struct TutorialStep: View {
    let number: Int
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.body)
                .foregroundColor(.white)

            Spacer()
        }
    }
}

#Preview {
    MainMapView()
        .environmentObject(AuthViewModel())
}
