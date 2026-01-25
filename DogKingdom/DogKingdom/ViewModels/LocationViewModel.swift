import Foundation
import CoreLocation
import Combine
import SwiftUI

enum ClaimingState {
    case idle
    case tracking
    case validating
    case success(Territory)
    case failed(String)
}

class LocationViewModel: ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var pathPoints: [PathPoint] = []
    @Published var claimingState: ClaimingState = .idle
    @Published var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var pathLength: Double = 0
    @Published var distanceToStart: Double = 0
    @Published var estimatedArea: Double = 0

    private let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()

    // User info for creating territories
    var userId: String = ""
    var userName: String = ""

    init() {
        setupBindings()
    }

    private func setupBindings() {
        locationService.$currentLocation
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentLocation)

        locationService.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$authorizationStatus)
    }

    func requestLocationPermission() {
        locationService.requestPermission()
    }

    func startUpdatingLocation() {
        locationService.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationService.stopUpdatingLocation()
    }

    // MARK: - Claiming Flow

    func startClaiming() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }

        pathPoints = []
        pathLength = 0
        distanceToStart = 0
        estimatedArea = 0
        claimingState = .tracking

        locationService.startTracking { [weak self] location in
            self?.handleLocationUpdate(location)
        }
    }

    func cancelClaiming() {
        locationService.stopTracking()
        pathPoints = []
        pathLength = 0
        distanceToStart = 0
        estimatedArea = 0
        claimingState = .idle
    }

    private func handleLocationUpdate(_ location: CLLocation) {
        let newPoint = PathPoint(from: location)
        pathPoints.append(newPoint)

        // Update progress metrics
        let progress = PolygonDetector.getProgress(points: pathPoints)
        pathLength = progress.pathLength
        distanceToStart = progress.distanceToStart
        estimatedArea = progress.estimatedArea

        // Check if loop is potentially closed
        checkForLoopClosure()
    }

    private func checkForLoopClosure() {
        guard pathPoints.count >= PolygonDetector.minimumPoints,
              pathLength >= PolygonDetector.minimumPathLength,
              let first = pathPoints.first,
              let last = pathPoints.last else {
            return
        }

        // Check if we're close to the starting point
        if PolygonDetector.isLoopClosed(start: first.coordinate, current: last.coordinate) {
            attemptToClaimTerritory()
        }
    }

    func attemptToClaimTerritory() {
        locationService.stopTracking()
        claimingState = .validating

        // Process path with interpolation for any signal gaps
        let processedPoints = PolygonDetector.processPathWithInterpolation(points: pathPoints)

        // Detect polygon from path
        let result = PolygonDetector.detectPolygon(from: processedPoints)

        if result.isValid, let coordinates = result.coordinates {
            let territory = Territory(
                ownerId: userId,
                ownerName: userName,
                coordinates: coordinates,
                color: Territory.colorForUser(userId)
            )
            claimingState = .success(territory)
        } else {
            claimingState = .failed(result.failureReason ?? "Invalid territory")
        }
    }

    func resetClaimingState() {
        pathPoints = []
        pathLength = 0
        distanceToStart = 0
        estimatedArea = 0
        claimingState = .idle
    }

    // MARK: - Path Coordinates for Map Display

    var pathCoordinates: [CLLocationCoordinate2D] {
        pathPoints.map { $0.coordinate }
    }

    var isTracking: Bool {
        if case .tracking = claimingState { return true }
        return false
    }

    var statusMessage: String {
        switch claimingState {
        case .idle:
            return "Tap 'Start Claiming' to begin"
        case .tracking:
            if pathPoints.count < PolygonDetector.minimumPoints {
                return "Keep walking... (\(pathPoints.count)/\(PolygonDetector.minimumPoints) points)"
            } else if pathLength < PolygonDetector.minimumPathLength {
                return "Path: \(Int(pathLength))m / \(Int(PolygonDetector.minimumPathLength))m minimum"
            } else if estimatedArea < PolygonDetector.minimumArea {
                return "Area: \(Int(estimatedArea))m² / \(Int(PolygonDetector.minimumArea))m² minimum"
            } else {
                return "Return to start! Distance: \(Int(distanceToStart))m"
            }
        case .validating:
            return "Validating your territory..."
        case .success:
            return "Territory claimed!"
        case .failed(let reason):
            return reason
        }
    }

    var canAttemptClaim: Bool {
        return pathPoints.count >= PolygonDetector.minimumPoints &&
               pathLength >= PolygonDetector.minimumPathLength &&
               estimatedArea >= PolygonDetector.minimumArea * 0.8 // Allow some tolerance
    }

    // MARK: - Progress Percentages for UI

    var pathLengthProgress: Double {
        min(pathLength / PolygonDetector.minimumPathLength, 1.0)
    }

    var pointCountProgress: Double {
        min(Double(pathPoints.count) / Double(PolygonDetector.minimumPoints), 1.0)
    }

    var areaProgress: Double {
        min(estimatedArea / PolygonDetector.minimumArea, 1.0)
    }

    var isReadyToClose: Bool {
        return pathLengthProgress >= 1.0 &&
               pointCountProgress >= 1.0 &&
               areaProgress >= 0.8
    }
}
