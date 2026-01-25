import Foundation
import CoreLocation

struct PolygonDetectionResult {
    let isValid: Bool
    let coordinates: [CLLocationCoordinate2D]?
    let area: Double?
    let failureReason: String?

    static func invalid(_ reason: String) -> PolygonDetectionResult {
        PolygonDetectionResult(isValid: false, coordinates: nil, area: nil, failureReason: reason)
    }

    static func valid(coordinates: [CLLocationCoordinate2D], area: Double) -> PolygonDetectionResult {
        PolygonDetectionResult(isValid: true, coordinates: coordinates, area: area, failureReason: nil)
    }
}

class PolygonDetector {
    // Configuration constants
    static let minimumPathLength: Double = 50 // meters
    static let loopClosureThreshold: Double = 15 // meters - how close end must be to start
    static let minimumPoints: Int = 10
    static let minimumRadius: Double = 25 // meters (25m radius equivalent)
    static let minimumArea: Double = Double.pi * 25 * 25 // ~1963 m²
    static let simplificationEpsilon: Double = 2.0 // meters for Douglas-Peucker
    static let smoothingWindowSize: Int = 3

    /// Check if the current point is close enough to the start point to close the loop
    static func isLoopClosed(start: CLLocationCoordinate2D, current: CLLocationCoordinate2D) -> Bool {
        let distance = GeoUtils.distance(from: start, to: current)
        return distance <= loopClosureThreshold
    }

    /// Calculate total path length from array of points
    static func pathLength(points: [PathPoint]) -> Double {
        guard points.count >= 2 else { return 0 }

        var totalDistance: Double = 0
        for i in 1..<points.count {
            totalDistance += GeoUtils.distance(from: points[i-1].coordinate, to: points[i].coordinate)
        }
        return totalDistance
    }

    /// Analyze path points and determine if they form a valid closed polygon
    static func detectPolygon(from points: [PathPoint]) -> PolygonDetectionResult {
        // Check minimum points
        guard points.count >= minimumPoints else {
            return .invalid("Not enough points recorded. Keep walking!")
        }

        // Check path length
        let totalLength = pathLength(points: points)
        guard totalLength >= minimumPathLength else {
            return .invalid("Path too short. Walk at least \(Int(minimumPathLength))m.")
        }

        // Check loop closure
        guard let first = points.first, let last = points.last else {
            return .invalid("No path recorded.")
        }

        guard isLoopClosed(start: first.coordinate, current: last.coordinate) else {
            let distance = GeoUtils.distance(from: first.coordinate, to: last.coordinate)
            return .invalid("Return to start! You're \(Int(distance))m away.")
        }

        // Extract coordinates
        var coordinates = points.map { $0.coordinate }

        // Apply GPS smoothing
        coordinates = GeoUtils.smoothCoordinates(coordinates, windowSize: smoothingWindowSize)

        // Handle self-intersections - take largest loop
        if let largestLoop = GeoUtils.findLargestLoop(in: coordinates) {
            coordinates = largestLoop
        }

        // Simplify polygon using Douglas-Peucker
        coordinates = GeoUtils.simplifyPolygon(coordinates: coordinates, epsilon: simplificationEpsilon)

        // Ensure polygon is closed (last point = first point for rendering)
        if let first = coordinates.first, let last = coordinates.last {
            if first != last {
                coordinates.append(first)
            }
        }

        // Check minimum points after simplification
        guard coordinates.count >= 4 else { // 4 because last point is duplicate of first
            return .invalid("Path too simple. Walk a larger area.")
        }

        // Calculate area
        let area = GeoUtils.polygonArea(coordinates: coordinates)

        // Check minimum area (25m radius equivalent)
        guard area >= minimumArea else {
            let neededArea = Int(minimumArea - area)
            return .invalid("Territory too small. Need \(neededArea)m² more area.")
        }

        return .valid(coordinates: coordinates, area: area)
    }

    /// Process raw path points with interpolation for signal gaps
    static func processPathWithInterpolation(points: [PathPoint], maxGapSeconds: TimeInterval = 10) -> [PathPoint] {
        guard points.count >= 2 else { return points }

        var processed: [PathPoint] = [points[0]]

        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let timeDiff = curr.timestamp.timeIntervalSince(prev.timestamp)

            // If gap is too large, interpolate points
            if timeDiff > maxGapSeconds {
                let numInterpolations = Int(timeDiff / 3) // One point every 3 seconds
                for j in 1..<numInterpolations {
                    let fraction = Double(j) / Double(numInterpolations)
                    let interpLat = prev.coordinate.latitude + fraction * (curr.coordinate.latitude - prev.coordinate.latitude)
                    let interpLon = prev.coordinate.longitude + fraction * (curr.coordinate.longitude - prev.coordinate.longitude)
                    let interpTime = prev.timestamp.addingTimeInterval(timeDiff * fraction)

                    let interpPoint = PathPoint(
                        coordinate: CLLocationCoordinate2D(latitude: interpLat, longitude: interpLon),
                        timestamp: interpTime,
                        accuracy: max(prev.accuracy, curr.accuracy)
                    )
                    processed.append(interpPoint)
                }
            }

            processed.append(curr)
        }

        return processed
    }

    /// Get distance remaining to close the loop
    static func distanceToClose(points: [PathPoint]) -> Double? {
        guard let first = points.first, let last = points.last else {
            return nil
        }
        return GeoUtils.distance(from: first.coordinate, to: last.coordinate)
    }

    /// Get current progress metrics for UI display
    static func getProgress(points: [PathPoint]) -> (pathLength: Double, pointCount: Int, distanceToStart: Double, estimatedArea: Double) {
        let length = pathLength(points: points)
        let count = points.count
        let distance = distanceToClose(points: points) ?? 0

        // Estimate area if we were to close the loop now
        var estimatedArea: Double = 0
        if count >= 3 {
            var coords = points.map { $0.coordinate }
            if let first = coords.first {
                coords.append(first) // Close the loop
            }
            estimatedArea = GeoUtils.polygonArea(coordinates: coords)
        }

        return (length, count, distance, estimatedArea)
    }
}
