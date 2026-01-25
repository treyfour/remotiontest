import Foundation
import CoreLocation
import Combine

enum LocationAuthorizationStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedWhenInUse
    case authorizedAlways
}

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var isTracking = false
    @Published var trackingError: Error?

    private var locationUpdateHandler: ((CLLocation) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3 // meters - update every 3 meters
        locationManager.activityType = .fitness
        updateAuthorizationStatus()
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func startTracking(onLocationUpdate: @escaping (CLLocation) -> Void) {
        locationUpdateHandler = onLocationUpdate
        isTracking = true
        startUpdatingLocation()
    }

    func stopTracking() {
        locationUpdateHandler = nil
        isTracking = false
        stopUpdatingLocation()
    }

    private func updateAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .restricted:
            authorizationStatus = .restricted
        case .denied:
            authorizationStatus = .denied
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
        case .authorizedAlways:
            authorizationStatus = .authorizedAlways
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Filter out inaccurate locations
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= 20 else {
            return
        }

        currentLocation = location

        if isTracking {
            locationUpdateHandler?(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        trackingError = error
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthorizationStatus()
    }
}
