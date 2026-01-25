import SwiftUI

struct ClaimingHUD: View {
    @ObservedObject var locationViewModel: LocationViewModel
    var onClaimComplete: (Territory) -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Status message
            Text(locationViewModel.statusMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Progress indicators when tracking
            if locationViewModel.isTracking {
                TrackingProgressView(
                    pathLength: locationViewModel.pathLength,
                    pathLengthProgress: locationViewModel.pathLengthProgress,
                    estimatedArea: locationViewModel.estimatedArea,
                    areaProgress: locationViewModel.areaProgress,
                    distanceToStart: locationViewModel.distanceToStart,
                    pointCount: locationViewModel.pathPoints.count,
                    isReadyToClose: locationViewModel.isReadyToClose
                )
            }

            // Action buttons
            HStack(spacing: 16) {
                switch locationViewModel.claimingState {
                case .idle:
                    StartClaimButton {
                        locationViewModel.startClaiming()
                    }

                case .tracking:
                    CancelButton {
                        locationViewModel.cancelClaiming()
                    }

                    if locationViewModel.canAttemptClaim {
                        ForceClaimButton {
                            locationViewModel.attemptToClaimTerritory()
                        }
                    }

                case .validating:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)

                case .success(let territory):
                    SuccessView(territory: territory) {
                        onClaimComplete(territory)
                    }

                case .failed:
                    FailureView {
                        locationViewModel.resetClaimingState()
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

// MARK: - Progress View

struct TrackingProgressView: View {
    let pathLength: Double
    let pathLengthProgress: Double
    let estimatedArea: Double
    let areaProgress: Double
    let distanceToStart: Double
    let pointCount: Int
    let isReadyToClose: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Progress bars
            HStack(spacing: 16) {
                ProgressBar(
                    progress: pathLengthProgress,
                    label: "Distance",
                    value: "\(Int(pathLength))m",
                    color: .blue
                )

                ProgressBar(
                    progress: areaProgress,
                    label: "Area",
                    value: formatArea(estimatedArea),
                    color: .green
                )
            }

            // Distance to start indicator
            HStack {
                Image(systemName: isReadyToClose ? "checkmark.circle.fill" : "arrow.uturn.backward.circle")
                    .foregroundColor(isReadyToClose ? .green : .orange)

                Text(isReadyToClose ? "Ready! Return to start (\(Int(distanceToStart))m)" : "\(Int(distanceToStart))m to start")
                    .font(.caption)
                    .foregroundColor(isReadyToClose ? .green : .secondary)

                Spacer()

                Text("\(pointCount) pts")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }

    private func formatArea(_ area: Double) -> String {
        if area >= 1000 {
            return String(format: "%.1fk", area / 1000)
        } else {
            return String(format: "%.0f", area)
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(progress >= 1.0 ? Color.green : color)
                        .frame(width: geometry.size.width * min(progress, 1.0))
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Action Buttons

struct StartClaimButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "pawprint.fill")
                Text("Start Claiming")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .blue.opacity(0.4), radius: 8, y: 4)
        }
    }
}

struct CancelButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "xmark")
                Text("Cancel")
            }
            .font(.subheadline)
            .foregroundColor(.red)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.red.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

struct ForceClaimButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Claim Now")
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.green)
            .cornerRadius(20)
        }
    }
}

struct SuccessView: View {
    let territory: Territory
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)

            Text("Territory Claimed!")
                .font(.headline)

            Text("\(Int(territory.area)) m²")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)

            Button("Confirm") {
                action()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct FailureView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text("Try Again")
                .font(.headline)

            Button("OK") {
                action()
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        ClaimingHUD(
            locationViewModel: LocationViewModel(),
            onClaimComplete: { _ in }
        )
        .padding()
    }
    .background(Color.gray.opacity(0.3))
}
