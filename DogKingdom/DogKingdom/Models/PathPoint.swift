import Foundation
import CoreLocation

struct PathPoint: Identifiable, Equatable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    let accuracy: Double // horizontal accuracy in meters

    init(coordinate: CLLocationCoordinate2D, timestamp: Date = Date(), accuracy: Double = 0) {
        self.id = UUID()
        self.coordinate = coordinate
        self.timestamp = timestamp
        self.accuracy = accuracy
    }

    init(from location: CLLocation) {
        self.id = UUID()
        self.coordinate = location.coordinate
        self.timestamp = location.timestamp
        self.accuracy = location.horizontalAccuracy
    }

    static func == (lhs: PathPoint, rhs: PathPoint) -> Bool {
        lhs.id == rhs.id
    }
}
