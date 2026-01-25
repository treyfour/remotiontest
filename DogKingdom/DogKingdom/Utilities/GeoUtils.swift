import Foundation
import CoreLocation

struct GeoUtils {
    /// Earth's radius in meters
    static let earthRadius: Double = 6371000

    // MARK: - Distance Calculations

    /// Calculate distance between two coordinates in meters using Haversine formula
    static func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude.degreesToRadians
        let lat2 = to.latitude.degreesToRadians
        let deltaLat = (to.latitude - from.latitude).degreesToRadians
        let deltaLon = (to.longitude - from.longitude).degreesToRadians

        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(deltaLon / 2) * sin(deltaLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadius * c
    }

    /// Calculate bearing from one coordinate to another (in degrees)
    static func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude.degreesToRadians
        let lat2 = to.latitude.degreesToRadians
        let deltaLon = (to.longitude - from.longitude).degreesToRadians

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)

        let bearing = atan2(y, x).radiansToDegrees

        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    /// Calculate a destination coordinate given a start point, bearing, and distance
    static func destination(from: CLLocationCoordinate2D, bearing: Double, distance: Double) -> CLLocationCoordinate2D {
        let lat1 = from.latitude.degreesToRadians
        let lon1 = from.longitude.degreesToRadians
        let bearingRad = bearing.degreesToRadians
        let angularDistance = distance / earthRadius

        let lat2 = asin(sin(lat1) * cos(angularDistance) +
                       cos(lat1) * sin(angularDistance) * cos(bearingRad))

        let lon2 = lon1 + atan2(sin(bearingRad) * sin(angularDistance) * cos(lat1),
                                cos(angularDistance) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(
            latitude: lat2.radiansToDegrees,
            longitude: lon2.radiansToDegrees
        )
    }

    /// Check if a coordinate is valid
    static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return CLLocationCoordinate2DIsValid(coordinate) &&
               coordinate.latitude != 0 &&
               coordinate.longitude != 0
    }

    // MARK: - Polygon Calculations

    /// Calculate area of a polygon in square meters using Shoelace formula
    /// Coordinates should form a closed polygon (last point connects to first)
    static func polygonArea(coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count >= 3 else { return 0 }

        // Convert to local Cartesian coordinates for accurate area calculation
        let center = polygonCentroid(coordinates: coordinates)
        let localPoints = coordinates.map { coord -> (x: Double, y: Double) in
            let dx = distance(from: center, to: CLLocationCoordinate2D(latitude: center.latitude, longitude: coord.longitude))
            let dy = distance(from: center, to: CLLocationCoordinate2D(latitude: coord.latitude, longitude: center.longitude))
            let xSign = coord.longitude >= center.longitude ? 1.0 : -1.0
            let ySign = coord.latitude >= center.latitude ? 1.0 : -1.0
            return (x: dx * xSign, y: dy * ySign)
        }

        // Shoelace formula
        var area: Double = 0
        for i in 0..<localPoints.count {
            let j = (i + 1) % localPoints.count
            area += localPoints[i].x * localPoints[j].y
            area -= localPoints[j].x * localPoints[i].y
        }

        return abs(area) / 2.0
    }

    /// Calculate the centroid (geometric center) of a polygon
    static func polygonCentroid(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !coordinates.isEmpty else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }

        let totalLat = coordinates.reduce(0) { $0 + $1.latitude }
        let totalLon = coordinates.reduce(0) { $0 + $1.longitude }
        let count = Double(coordinates.count)

        return CLLocationCoordinate2D(
            latitude: totalLat / count,
            longitude: totalLon / count
        )
    }

    /// Calculate bounding box for a polygon
    static func polygonBoundingBox(coordinates: [CLLocationCoordinate2D]) -> (min: CLLocationCoordinate2D, max: CLLocationCoordinate2D)? {
        guard !coordinates.isEmpty else { return nil }

        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude

        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }

        return (
            min: CLLocationCoordinate2D(latitude: minLat, longitude: minLon),
            max: CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon)
        )
    }

    /// Calculate approximate "radius" of a polygon (average distance from centroid to vertices)
    static func polygonApproximateRadius(coordinates: [CLLocationCoordinate2D]) -> Double {
        guard !coordinates.isEmpty else { return 0 }
        let center = polygonCentroid(coordinates: coordinates)
        let distances = coordinates.map { distance(from: center, to: $0) }
        return distances.reduce(0, +) / Double(distances.count)
    }

    // MARK: - Douglas-Peucker Simplification

    /// Simplify a polygon using Douglas-Peucker algorithm
    /// - Parameters:
    ///   - coordinates: The polygon vertices
    ///   - epsilon: Tolerance in meters (points within this distance of line are removed)
    /// - Returns: Simplified polygon with fewer vertices
    static func simplifyPolygon(coordinates: [CLLocationCoordinate2D], epsilon: Double = 2.0) -> [CLLocationCoordinate2D] {
        guard coordinates.count > 2 else { return coordinates }

        return douglasPeucker(points: coordinates, epsilon: epsilon)
    }

    private static func douglasPeucker(points: [CLLocationCoordinate2D], epsilon: Double) -> [CLLocationCoordinate2D] {
        guard points.count > 2 else { return points }

        var maxDistance: Double = 0
        var maxIndex = 0

        let first = points.first!
        let last = points.last!

        for i in 1..<(points.count - 1) {
            let d = perpendicularDistance(point: points[i], lineStart: first, lineEnd: last)
            if d > maxDistance {
                maxDistance = d
                maxIndex = i
            }
        }

        if maxDistance > epsilon {
            let left = douglasPeucker(points: Array(points[0...maxIndex]), epsilon: epsilon)
            let right = douglasPeucker(points: Array(points[maxIndex...]), epsilon: epsilon)
            return Array(left.dropLast()) + right
        } else {
            return [first, last]
        }
    }

    /// Calculate perpendicular distance from a point to a line segment
    private static func perpendicularDistance(point: CLLocationCoordinate2D, lineStart: CLLocationCoordinate2D, lineEnd: CLLocationCoordinate2D) -> Double {
        let dx = lineEnd.longitude - lineStart.longitude
        let dy = lineEnd.latitude - lineStart.latitude

        if dx == 0 && dy == 0 {
            return distance(from: point, to: lineStart)
        }

        let t = max(0, min(1, ((point.longitude - lineStart.longitude) * dx + (point.latitude - lineStart.latitude) * dy) / (dx * dx + dy * dy)))

        let projection = CLLocationCoordinate2D(
            latitude: lineStart.latitude + t * dy,
            longitude: lineStart.longitude + t * dx
        )

        return distance(from: point, to: projection)
    }

    // MARK: - Point in Polygon

    /// Check if a point is inside a polygon using ray casting algorithm
    static func isPoint(_ point: CLLocationCoordinate2D, insidePolygon polygon: [CLLocationCoordinate2D]) -> Bool {
        guard polygon.count >= 3 else { return false }

        var inside = false
        var j = polygon.count - 1

        for i in 0..<polygon.count {
            let xi = polygon[i].longitude
            let yi = polygon[i].latitude
            let xj = polygon[j].longitude
            let yj = polygon[j].latitude

            let intersect = ((yi > point.latitude) != (yj > point.latitude)) &&
                           (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi)

            if intersect {
                inside = !inside
            }
            j = i
        }

        return inside
    }

    // MARK: - Polygon Intersection

    /// Check if two polygons overlap
    static func polygonsOverlap(_ polygon1: [CLLocationCoordinate2D], _ polygon2: [CLLocationCoordinate2D]) -> Bool {
        // Quick bounding box check first
        guard let bbox1 = polygonBoundingBox(coordinates: polygon1),
              let bbox2 = polygonBoundingBox(coordinates: polygon2) else {
            return false
        }

        // If bounding boxes don't overlap, polygons don't overlap
        if bbox1.max.latitude < bbox2.min.latitude ||
           bbox1.min.latitude > bbox2.max.latitude ||
           bbox1.max.longitude < bbox2.min.longitude ||
           bbox1.min.longitude > bbox2.max.longitude {
            return false
        }

        // Check if any vertex of polygon1 is inside polygon2
        for point in polygon1 {
            if isPoint(point, insidePolygon: polygon2) {
                return true
            }
        }

        // Check if any vertex of polygon2 is inside polygon1
        for point in polygon2 {
            if isPoint(point, insidePolygon: polygon1) {
                return true
            }
        }

        // Check if any edges intersect
        for i in 0..<polygon1.count {
            let a1 = polygon1[i]
            let a2 = polygon1[(i + 1) % polygon1.count]

            for j in 0..<polygon2.count {
                let b1 = polygon2[j]
                let b2 = polygon2[(j + 1) % polygon2.count]

                if lineSegmentsIntersect(a1: a1, a2: a2, b1: b1, b2: b2) {
                    return true
                }
            }
        }

        return false
    }

    /// Check if two line segments intersect
    private static func lineSegmentsIntersect(a1: CLLocationCoordinate2D, a2: CLLocationCoordinate2D,
                                               b1: CLLocationCoordinate2D, b2: CLLocationCoordinate2D) -> Bool {
        let d1 = direction(a1, a2, b1)
        let d2 = direction(a1, a2, b2)
        let d3 = direction(b1, b2, a1)
        let d4 = direction(b1, b2, a2)

        if ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
           ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)) {
            return true
        }

        if d1 == 0 && onSegment(a1, b1, a2) { return true }
        if d2 == 0 && onSegment(a1, b2, a2) { return true }
        if d3 == 0 && onSegment(b1, a1, b2) { return true }
        if d4 == 0 && onSegment(b1, a2, b2) { return true }

        return false
    }

    private static func direction(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D, _ c: CLLocationCoordinate2D) -> Double {
        return (c.longitude - a.longitude) * (b.latitude - a.latitude) - (b.longitude - a.longitude) * (c.latitude - a.latitude)
    }

    private static func onSegment(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D, _ c: CLLocationCoordinate2D) -> Bool {
        return min(a.longitude, c.longitude) <= b.longitude &&
               b.longitude <= max(a.longitude, c.longitude) &&
               min(a.latitude, c.latitude) <= b.latitude &&
               b.latitude <= max(a.latitude, c.latitude)
    }

    // MARK: - Polygon Subtraction (Carving)

    /// Subtract polygon2 from polygon1, returning remaining pieces
    /// Returns array of polygons (may return multiple if polygon1 is split into pieces)
    /// For MVP, returns simplified result - original minus overlapping area
    static func subtractPolygon(_ polygon1: [CLLocationCoordinate2D], minus polygon2: [CLLocationCoordinate2D]) -> [[CLLocationCoordinate2D]] {
        // If no overlap, return original
        guard polygonsOverlap(polygon1, polygon2) else {
            return [polygon1]
        }

        // For MVP: Return points from polygon1 that are NOT inside polygon2
        // This is a simplified approach - full polygon boolean operations are complex
        var remainingPoints: [CLLocationCoordinate2D] = []

        for point in polygon1 {
            if !isPoint(point, insidePolygon: polygon2) {
                remainingPoints.append(point)
            }
        }

        // If too few points remain, the territory is effectively claimed
        if remainingPoints.count < 3 {
            return []
        }

        // Ensure the polygon is still valid
        let area = polygonArea(coordinates: remainingPoints)
        let minArea = Double.pi * 25 * 25 // Minimum 25m radius equivalent

        if area < minArea {
            return [] // Territory too small, drop it
        }

        return [remainingPoints]
    }

    // MARK: - Kalman Filter for GPS Smoothing

    /// Apply simple smoothing to GPS coordinates
    static func smoothCoordinates(_ coordinates: [CLLocationCoordinate2D], windowSize: Int = 3) -> [CLLocationCoordinate2D] {
        guard coordinates.count > windowSize else { return coordinates }

        var smoothed: [CLLocationCoordinate2D] = []

        for i in 0..<coordinates.count {
            let start = max(0, i - windowSize / 2)
            let end = min(coordinates.count - 1, i + windowSize / 2)
            let window = Array(coordinates[start...end])

            let avgLat = window.reduce(0) { $0 + $1.latitude } / Double(window.count)
            let avgLon = window.reduce(0) { $0 + $1.longitude } / Double(window.count)

            smoothed.append(CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon))
        }

        return smoothed
    }

    // MARK: - Path Length

    /// Calculate total length of a path in meters
    static func pathLength(coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count >= 2 else { return 0 }

        var total: Double = 0
        for i in 1..<coordinates.count {
            total += distance(from: coordinates[i-1], to: coordinates[i])
        }
        return total
    }

    // MARK: - Self-Intersection Detection

    /// Find the largest non-self-intersecting loop in a path
    /// If path crosses itself, returns the largest enclosed area
    static func findLargestLoop(in path: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]? {
        guard path.count >= 3 else { return nil }

        // For MVP: Simple approach - if path has self-intersection, try to find largest simple loop
        // Check for self-intersections
        var intersections: [(index1: Int, index2: Int)] = []

        for i in 0..<path.count - 2 {
            for j in (i + 2)..<path.count - 1 {
                if i == 0 && j == path.count - 2 { continue } // Skip adjacent segments at endpoints

                if lineSegmentsIntersect(a1: path[i], a2: path[i + 1], b1: path[j], b2: path[j + 1]) {
                    intersections.append((i, j))
                }
            }
        }

        if intersections.isEmpty {
            // No self-intersection, return the whole path
            return path
        }

        // Find the largest loop by area
        var largestLoop: [CLLocationCoordinate2D]?
        var largestArea: Double = 0

        for (idx1, idx2) in intersections {
            // Loop from idx1 to idx2
            let loop1 = Array(path[idx1...idx2])
            let area1 = polygonArea(coordinates: loop1)

            if area1 > largestArea {
                largestArea = area1
                largestLoop = loop1
            }

            // Also check the other segment
            let loop2 = Array(path[0...idx1]) + Array(path[idx2...])
            let area2 = polygonArea(coordinates: loop2)

            if area2 > largestArea {
                largestArea = area2
                largestLoop = loop2
            }
        }

        return largestLoop ?? path
    }
}

// MARK: - Extensions

extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180
    }

    var radiansToDegrees: Double {
        return self * 180 / .pi
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
