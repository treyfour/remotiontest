import Foundation
import MapKit
import Combine

class MapViewModel: ObservableObject {
    @Published var territories: [Territory] = []
    @Published var region: MKCoordinateRegion
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTerritory: Territory?

    private let firebaseService = FirebaseService.shared
    private var cancellables = Set<AnyCancellable>()

    var currentUserId: String = ""

    init() {
        // Default region (will be updated when location is available)
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )

        setupBindings()
    }

    private func setupBindings() {
        firebaseService.$territories
            .receive(on: DispatchQueue.main)
            .assign(to: &$territories)

        firebaseService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        firebaseService.$error
            .receive(on: DispatchQueue.main)
            .map { $0?.localizedDescription }
            .assign(to: &$errorMessage)
    }

    func startListening() {
        firebaseService.startListeningToTerritories()
    }

    func stopListening() {
        firebaseService.stopListeningToTerritories()
    }

    func centerOnLocation(_ location: CLLocation) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }

    // MARK: - Territory Operations

    /// Save a new territory, carving into existing territories as needed
    func saveTerritory(_ territory: Territory) async -> Bool {
        // Validate the territory
        let validationResult = TerritoryValidator.validate(territory: territory)
        guard validationResult.isValid else {
            await MainActor.run {
                self.errorMessage = validationResult.errorMessage
            }
            return false
        }

        // Process carving - find overlapping territories and update them
        let carveResult = TerritoryValidator.processNewClaim(
            newTerritory: territory,
            existingTerritories: territories
        )

        do {
            // Save the new territory
            try await firebaseService.saveTerritory(carveResult.newTerritory)

            // Update carved territories
            for updated in carveResult.updatedTerritories {
                try await firebaseService.updateTerritoryCoordinates(updated)
            }

            // Delete consumed territories
            for deletedId in carveResult.deletedTerritoryIds {
                try await firebaseService.deleteTerritory(deletedId)
            }

            // Update user stats
            try await firebaseService.updateUserStats(
                userId: territory.ownerId,
                addedArea: territory.area
            )

            return true
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }

    // MARK: - Territory Queries

    var userTerritories: [Territory] {
        territories.filter { $0.ownerId == currentUserId }
    }

    var otherTerritories: [Territory] {
        territories.filter { $0.ownerId != currentUserId }
    }

    var totalUserArea: Double {
        TerritoryValidator.totalArea(for: currentUserId, in: territories)
    }

    var userTerritoryCount: Int {
        TerritoryValidator.territoryCount(for: currentUserId, in: territories)
    }

    func territoryAt(location: CLLocationCoordinate2D) -> Territory? {
        TerritoryValidator.territoriesContaining(point: location, in: territories).first
    }

    // MARK: - Map Region

    func zoomToFitTerritories() {
        guard !territories.isEmpty else { return }

        var allCoordinates: [CLLocationCoordinate2D] = []
        for territory in territories {
            allCoordinates.append(contentsOf: territory.coordinates)
        }

        guard let bbox = GeoUtils.polygonBoundingBox(coordinates: allCoordinates) else { return }

        let center = CLLocationCoordinate2D(
            latitude: (bbox.min.latitude + bbox.max.latitude) / 2,
            longitude: (bbox.min.longitude + bbox.max.longitude) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (bbox.max.latitude - bbox.min.latitude) * 1.2,
            longitudeDelta: (bbox.max.longitude - bbox.min.longitude) * 1.2
        )

        region = MKCoordinateRegion(center: center, span: span)
    }

    func clearError() {
        errorMessage = nil
    }
}
