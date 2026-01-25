import SwiftUI
import MapKit

// MARK: - UIKit Map View with Polygon Overlays

struct TerritoryMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let territories: [Territory]
    let currentUserId: String
    let pathCoordinates: [CLLocationCoordinate2D]
    var onTerritoryTapped: ((Territory) -> Void)?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Only update region if significantly different
        let currentCenter = mapView.region.center
        let newCenter = region.center
        let threshold = 0.0001

        if abs(currentCenter.latitude - newCenter.latitude) > threshold ||
           abs(currentCenter.longitude - newCenter.longitude) > threshold {
            mapView.setRegion(region, animated: true)
        }

        // Remove old overlays
        mapView.removeOverlays(mapView.overlays)

        // Add territory polygons
        for territory in territories {
            let polygon = MKPolygon(coordinates: territory.coordinates, count: territory.coordinates.count)
            polygon.title = territory.id
            mapView.addOverlay(polygon)
        }

        // Add path polyline if tracking
        if pathCoordinates.count >= 2 {
            let polyline = MKPolyline(coordinates: pathCoordinates, count: pathCoordinates.count)
            polyline.title = "currentPath"
            mapView.addOverlay(polyline)

            // Add start point marker
            if let start = pathCoordinates.first {
                let startCircle = MKCircle(center: start, radius: 5)
                startCircle.title = "startPoint"
                mapView.addOverlay(startCircle)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TerritoryMapView

        init(_ parent: TerritoryMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            // Territory polygon
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)

                if let territory = parent.territories.first(where: { $0.id == polygon.title }) {
                    let isOwned = territory.ownerId == parent.currentUserId
                    let color = Color(hex: territory.color).map { UIColor($0) } ?? (isOwned ? .systemBlue : .systemRed)

                    renderer.fillColor = color.withAlphaComponent(0.3)
                    renderer.strokeColor = color
                    renderer.lineWidth = 2
                } else {
                    renderer.fillColor = UIColor.gray.withAlphaComponent(0.3)
                    renderer.strokeColor = .gray
                    renderer.lineWidth = 2
                }

                return renderer
            }

            // Current walking path
            if let polyline = overlay as? MKPolyline, polyline.title == "currentPath" {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemGreen
                renderer.lineWidth = 4
                renderer.lineDashPattern = [8, 4]
                return renderer
            }

            // Start point marker
            if let circle = overlay as? MKCircle, circle.title == "startPoint" {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = .systemGreen
                renderer.strokeColor = .white
                renderer.lineWidth = 2
                return renderer
            }

            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }

            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            // Find territory at this coordinate
            for territory in parent.territories {
                if territory.contains(point: coordinate) {
                    parent.onTerritoryTapped?(territory)
                    return
                }
            }
        }
    }
}

// MARK: - SwiftUI Territory Annotation (for simple map)

struct TerritoryAnnotationView: View {
    let territory: Territory
    let isOwned: Bool

    var body: some View {
        ZStack {
            // Paw print icon at centroid
            Image(systemName: "pawprint.fill")
                .font(.title2)
                .foregroundColor(territoryColor)
                .shadow(color: .black.opacity(0.3), radius: 2)

            // Crown for owned territories
            if isOwned {
                Image(systemName: "crown.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                    .offset(y: -15)
            }
        }
    }

    private var territoryColor: Color {
        Color(hex: territory.color) ?? (isOwned ? .blue : .red)
    }
}

// MARK: - Territory Info Card

struct TerritoryInfoCard: View {
    let territory: Territory
    let isOwned: Bool
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Circle()
                    .fill(Color(hex: territory.color) ?? .blue)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(territory.ownerName)
                        .font(.headline)

                    if isOwned {
                        Text("Your Territory")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Stats
            HStack(spacing: 20) {
                StatItem(label: "Area", value: formatArea(territory.area))
                StatItem(label: "Points", value: "\(territory.coordinates.count)")
                StatItem(label: "Claimed", value: formatDate(territory.claimedAt))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
    }

    private func formatArea(_ area: Double) -> String {
        if area >= 10000 {
            return String(format: "%.1f ha", area / 10000)
        } else {
            return String(format: "%.0f m²", area)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
