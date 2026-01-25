import Foundation
import CoreLocation
import FirebaseFirestore

struct Territory: Identifiable, Codable, Equatable {
    let id: String
    let ownerId: String
    let ownerName: String
    let coordinates: [CLLocationCoordinate2D] // Polygon vertices
    let claimedAt: Date
    let color: String // hex color

    // Computed properties
    var area: Double {
        GeoUtils.polygonArea(coordinates: coordinates)
    }

    var centroid: CLLocationCoordinate2D {
        GeoUtils.polygonCentroid(coordinates: coordinates)
    }

    var approximateRadius: Double {
        GeoUtils.polygonApproximateRadius(coordinates: coordinates)
    }

    init(id: String = UUID().uuidString,
         ownerId: String,
         ownerName: String,
         coordinates: [CLLocationCoordinate2D],
         claimedAt: Date = Date(),
         color: String) {
        self.id = id
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.coordinates = coordinates
        self.claimedAt = claimedAt
        self.color = color
    }

    // Custom Codable implementation for CLLocationCoordinate2D array
    enum CodingKeys: String, CodingKey {
        case id, ownerId, ownerName, claimedAt, color
        case coordinatesData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        ownerName = try container.decode(String.self, forKey: .ownerName)
        claimedAt = try container.decode(Date.self, forKey: .claimedAt)
        color = try container.decode(String.self, forKey: .color)

        let coordsData = try container.decode([[Double]].self, forKey: .coordinatesData)
        coordinates = coordsData.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(ownerName, forKey: .ownerName)
        try container.encode(claimedAt, forKey: .claimedAt)
        try container.encode(color, forKey: .color)

        let coordsData = coordinates.map { [$0.latitude, $0.longitude] }
        try container.encode(coordsData, forKey: .coordinatesData)
    }

    static func == (lhs: Territory, rhs: Territory) -> Bool {
        lhs.id == rhs.id
    }

    // Convert to Firestore document data
    func toFirestoreData() -> [String: Any] {
        // Store coordinates as array of GeoPoints
        let geoPoints = coordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }

        return [
            "id": id,
            "ownerId": ownerId,
            "ownerName": ownerName,
            "coordinates": geoPoints,
            "claimedAt": Timestamp(date: claimedAt),
            "color": color,
            "area": area // Store computed area for quick queries
        ]
    }

    // Create from Firestore document
    static func fromFirestore(_ document: DocumentSnapshot) -> Territory? {
        guard let data = document.data(),
              let ownerId = data["ownerId"] as? String,
              let ownerName = data["ownerName"] as? String,
              let geoPoints = data["coordinates"] as? [GeoPoint],
              let timestamp = data["claimedAt"] as? Timestamp,
              let color = data["color"] as? String else {
            return nil
        }

        let coordinates = geoPoints.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }

        guard coordinates.count >= 3 else { return nil }

        return Territory(
            id: document.documentID,
            ownerId: ownerId,
            ownerName: ownerName,
            coordinates: coordinates,
            claimedAt: timestamp.dateValue(),
            color: color
        )
    }

    // MARK: - Territory Operations

    /// Check if this territory contains a point
    func contains(point: CLLocationCoordinate2D) -> Bool {
        GeoUtils.isPoint(point, insidePolygon: coordinates)
    }

    /// Check if this territory overlaps with another
    func overlaps(with other: Territory) -> Bool {
        GeoUtils.polygonsOverlap(coordinates, other.coordinates)
    }

    /// Create a new territory with this territory carved by another
    /// Returns nil if the remaining area is too small
    func carved(by carver: Territory) -> Territory? {
        let remaining = GeoUtils.subtractPolygon(coordinates, minus: carver.coordinates)

        guard let newCoords = remaining.first, newCoords.count >= 3 else {
            return nil // Territory completely consumed or too small
        }

        return Territory(
            id: id,
            ownerId: ownerId,
            ownerName: ownerName,
            coordinates: newCoords,
            claimedAt: claimedAt,
            color: color
        )
    }

    /// Check if territory meets minimum size requirement (25m radius equivalent)
    var isValidSize: Bool {
        let minArea = Double.pi * 25 * 25 // ~1963 m²
        return area >= minArea
    }
}

// MARK: - Territory Color Assignment

extension Territory {
    /// Available territory colors
    static let availableColors = [
        "#FF6B6B", // Red
        "#4ECDC4", // Teal
        "#45B7D1", // Blue
        "#96CEB4", // Green
        "#FFEAA7", // Yellow
        "#DDA0DD", // Plum
        "#98D8C8", // Mint
        "#F7DC6F", // Gold
        "#BB8FCE", // Purple
        "#85C1E9", // Sky Blue
        "#F8B500", // Orange
        "#58D68D"  // Lime
    ]

    /// Get a color for a user based on their ID (consistent color per user)
    static func colorForUser(_ userId: String) -> String {
        let hash = abs(userId.hashValue)
        let index = hash % availableColors.count
        return availableColors[index]
    }
}
