import Foundation
import CoreLocation

enum TerritoryValidationResult {
    case valid
    case tooSmall
    case invalidShape
    case invalidLocation

    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .tooSmall:
            return "Territory is too small. Minimum size is ~1963m² (25m radius equivalent)."
        case .invalidShape:
            return "Invalid territory shape. Must have at least 3 vertices."
        case .invalidLocation:
            return "Invalid location for territory."
        }
    }
}

struct CarveResult {
    let updatedTerritories: [Territory] // Territories that were modified
    let deletedTerritoryIds: [String] // Territories that were completely consumed
    let newTerritory: Territory // The newly claimed territory
}

class TerritoryValidator {

    // MARK: - Basic Validation

    /// Validate a new territory meets basic requirements
    static func validate(territory: Territory) -> TerritoryValidationResult {
        // Check for valid coordinates
        for coord in territory.coordinates {
            guard CLLocationCoordinate2DIsValid(coord) else {
                return .invalidLocation
            }
        }

        // Check minimum vertices
        guard territory.coordinates.count >= 3 else {
            return .invalidShape
        }

        // Check minimum size
        guard territory.isValidSize else {
            return .tooSmall
        }

        return .valid
    }

    // MARK: - Overlap Detection

    /// Check if a territory overlaps with any existing territories
    static func findOverlaps(for newTerritory: Territory, in existingTerritories: [Territory]) -> [Territory] {
        return existingTerritories.filter { existing in
            // Don't check against own territories (same owner)
            guard existing.ownerId != newTerritory.ownerId else { return false }
            return newTerritory.overlaps(with: existing)
        }
    }

    /// Check if a point is inside any territory
    static func territoriesContaining(point: CLLocationCoordinate2D, in territories: [Territory]) -> [Territory] {
        return territories.filter { $0.contains(point: point) }
    }

    // MARK: - Territory Carving

    /// Process a new territory claim, carving into existing territories as needed
    /// Returns the result containing updated, deleted, and new territories
    static func processNewClaim(
        newTerritory: Territory,
        existingTerritories: [Territory]
    ) -> CarveResult {
        var updatedTerritories: [Territory] = []
        var deletedTerritoryIds: [String] = []

        // Find all territories that overlap with the new claim
        let overlapping = existingTerritories.filter { existing in
            // Can carve into any territory except your own
            guard existing.ownerId != newTerritory.ownerId else { return false }
            return newTerritory.overlaps(with: existing)
        }

        // Carve each overlapping territory
        for existing in overlapping {
            if let carved = existing.carved(by: newTerritory) {
                // Territory was carved but still valid
                updatedTerritories.append(carved)
            } else {
                // Territory was completely consumed or too small
                deletedTerritoryIds.append(existing.id)
            }
        }

        return CarveResult(
            updatedTerritories: updatedTerritories,
            deletedTerritoryIds: deletedTerritoryIds,
            newTerritory: newTerritory
        )
    }

    // MARK: - Area Calculations

    /// Calculate total area owned by a user
    static func totalArea(for userId: String, in territories: [Territory]) -> Double {
        return territories
            .filter { $0.ownerId == userId }
            .reduce(0) { $0 + $1.area }
    }

    /// Calculate territory count for a user
    static func territoryCount(for userId: String, in territories: [Territory]) -> Int {
        return territories.filter { $0.ownerId == userId }.count
    }

    // MARK: - Validation Helpers

    /// Check if coordinates form a valid polygon (no self-intersection, valid coords)
    static func isValidPolygon(_ coordinates: [CLLocationCoordinate2D]) -> Bool {
        guard coordinates.count >= 3 else { return false }

        // Check all coordinates are valid
        for coord in coordinates {
            guard CLLocationCoordinate2DIsValid(coord) else { return false }
        }

        // Calculate area - if zero, polygon is degenerate
        let area = GeoUtils.polygonArea(coordinates: coordinates)
        guard area > 0 else { return false }

        return true
    }

    /// Estimate if a path can form a valid territory when closed
    static func canFormValidTerritory(from points: [PathPoint]) -> (valid: Bool, reason: String?) {
        guard points.count >= PolygonDetector.minimumPoints else {
            return (false, "Need more points")
        }

        let coords = points.map { $0.coordinate }
        let area = GeoUtils.polygonArea(coordinates: coords)

        guard area >= PolygonDetector.minimumArea else {
            return (false, "Area too small")
        }

        return (true, nil)
    }
}
