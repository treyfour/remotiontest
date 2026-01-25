import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
import CoreLocation

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()

    private let db = Firestore.firestore()
    private var territoriesListener: ListenerRegistration?

    @Published var territories: [Territory] = []
    @Published var isLoading = false
    @Published var error: Error?

    private init() {}

    // MARK: - Territory Operations

    /// Start listening to all territories in real-time
    func startListeningToTerritories() {
        isLoading = true

        territoriesListener = db.collection("territories")
            .order(by: "claimedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.isLoading = false

                if let error = error {
                    self?.error = error
                    return
                }

                guard let documents = snapshot?.documents else {
                    self?.territories = []
                    return
                }

                self?.territories = documents.compactMap { Territory.fromFirestore($0) }
            }
    }

    /// Stop listening to territories
    func stopListeningToTerritories() {
        territoriesListener?.remove()
        territoriesListener = nil
    }

    /// Save a new territory to Firestore
    func saveTerritory(_ territory: Territory) async throws {
        try await db.collection("territories")
            .document(territory.id)
            .setData(territory.toFirestoreData())
    }

    /// Update territory coordinates (for carving)
    func updateTerritoryCoordinates(_ territory: Territory) async throws {
        let geoPoints = territory.coordinates.map {
            GeoPoint(latitude: $0.latitude, longitude: $0.longitude)
        }

        try await db.collection("territories")
            .document(territory.id)
            .updateData([
                "coordinates": geoPoints,
                "area": territory.area
            ])
    }

    /// Delete a territory
    func deleteTerritory(_ territoryId: String) async throws {
        try await db.collection("territories")
            .document(territoryId)
            .delete()
    }

    /// Get territories for a specific user
    func getTerritoriesForUser(_ userId: String) async throws -> [Territory] {
        let snapshot = try await db.collection("territories")
            .whereField("ownerId", isEqualTo: userId)
            .getDocuments()

        return snapshot.documents.compactMap { Territory.fromFirestore($0) }
    }

    /// Check if a territory would overlap with existing ones (server-side check)
    func checkForOverlaps(coordinates: [CLLocationCoordinate2D]) async throws -> [Territory] {
        // Fetch all territories and check locally
        // Note: For production, consider using GeoFirestore for efficient geo-queries
        let snapshot = try await db.collection("territories").getDocuments()
        let allTerritories = snapshot.documents.compactMap { Territory.fromFirestore($0) }

        // Create a temporary territory to check
        let tempTerritory = Territory(
            ownerId: "",
            ownerName: "",
            coordinates: coordinates,
            color: ""
        )

        return allTerritories.filter { $0.overlaps(with: tempTerritory) }
    }

    // MARK: - User Operations

    /// Create or update user profile
    func saveUser(_ user: AppUser) async throws {
        try await db.collection("users")
            .document(user.id)
            .setData(user.toFirestoreData(), merge: true)
    }

    /// Get user profile
    func getUser(_ userId: String) async throws -> AppUser? {
        let document = try await db.collection("users").document(userId).getDocument()

        guard let data = document.data(),
              let displayName = data["displayName"] as? String else {
            return nil
        }

        var user = AppUser(
            id: userId,
            displayName: displayName,
            email: data["email"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )

        user.territoriesCount = data["territoriesCount"] as? Int ?? 0
        user.totalAreaClaimed = data["totalAreaClaimed"] as? Double ?? 0

        return user
    }

    /// Update user stats after claiming territory
    func updateUserStats(userId: String, addedArea: Double) async throws {
        let userRef = db.collection("users").document(userId)

        try await db.runTransaction { transaction, errorPointer in
            let document: DocumentSnapshot
            do {
                document = try transaction.getDocument(userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            let currentCount = document.data()?["territoriesCount"] as? Int ?? 0
            let currentArea = document.data()?["totalAreaClaimed"] as? Double ?? 0

            transaction.updateData([
                "territoriesCount": currentCount + 1,
                "totalAreaClaimed": currentArea + addedArea
            ], forDocument: userRef)

            return nil
        }
    }

    /// Recalculate user stats (call when territories are carved)
    func recalculateUserStats(userId: String) async throws {
        let territories = try await getTerritoriesForUser(userId)
        let totalArea = territories.reduce(0) { $0 + $1.area }

        try await db.collection("users")
            .document(userId)
            .updateData([
                "territoriesCount": territories.count,
                "totalAreaClaimed": totalArea
            ])
    }

    // MARK: - Leaderboard

    /// Get top users by total area
    func getLeaderboard(limit: Int = 10) async throws -> [AppUser] {
        let snapshot = try await db.collection("users")
            .order(by: "totalAreaClaimed", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> AppUser? in
            guard let data = doc.data() as? [String: Any],
                  let displayName = data["displayName"] as? String else {
                return nil
            }

            var user = AppUser(
                id: doc.documentID,
                displayName: displayName,
                email: data["email"] as? String,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )

            user.territoriesCount = data["territoriesCount"] as? Int ?? 0
            user.totalAreaClaimed = data["totalAreaClaimed"] as? Double ?? 0

            return user
        }
    }
}
