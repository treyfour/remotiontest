# Dog Kingdom

A competitive location-based iOS game where users claim territory by walking in circles. Territories are shared between all users, creating a competitive "land grab" experience.

## Features

- **GPS Circle Detection**: Walk in circles to claim territory
- **Real-time Multiplayer**: See other players' territories on the map
- **Competitive Gameplay**: First come, first served - no overlapping claims
- **Apple Sign-In**: Secure authentication

## Requirements

- iOS 16.0+
- Xcode 15+
- Physical iPhone (GPS doesn't work well in Simulator)
- Apple Developer Account
- Firebase Project

## Setup

### 1. Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Add an iOS app with bundle ID: `com.dogkingdom.app`
4. Download `GoogleService-Info.plist`
5. Replace the placeholder file in `DogKingdom/GoogleService-Info.plist`

### 2. Enable Firebase Services

In the Firebase Console, enable:
- **Authentication**: Enable "Apple" sign-in provider
- **Firestore Database**: Create database in production mode

### 3. Firestore Security Rules

Add these rules to your Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Territories collection
    match /territories/{territoryId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.ownerId == request.auth.uid;
      allow delete: if request.auth != null
        && resource.data.ownerId == request.auth.uid;
    }
  }
}
```

### 4. Apple Sign-In Configuration

1. In your Apple Developer account, enable "Sign in with Apple" capability
2. In Xcode, add the "Sign in with Apple" capability to your target
3. Ensure your bundle ID matches Firebase configuration

### 5. Build and Run

1. Open `DogKingdom.xcodeproj` in Xcode
2. Wait for Swift Package Manager to resolve Firebase dependencies
3. Select your development team in Signing & Capabilities
4. Connect a physical iPhone
5. Build and run

## Project Structure

```
DogKingdom/
├── App/
│   └── DogKingdomApp.swift          # App entry point
├── Models/
│   ├── Territory.swift               # Territory data model
│   ├── User.swift                    # User profile model
│   └── PathPoint.swift               # GPS coordinate with timestamp
├── Views/
│   ├── MainMapView.swift             # Primary map interface
│   ├── TerritoryOverlay.swift        # Circle overlays on map
│   ├── ClaimingHUD.swift             # UI during active claiming
│   ├── AuthView.swift                # Login/signup screen
│   └── ProfileView.swift             # User stats and settings
├── ViewModels/
│   ├── MapViewModel.swift            # Map state and territory display
│   ├── LocationViewModel.swift       # GPS tracking and circle detection
│   └── AuthViewModel.swift           # Firebase auth state
├── Services/
│   ├── LocationService.swift         # Core Location wrapper
│   ├── CircleDetector.swift          # Algorithm to detect valid circles
│   ├── FirebaseService.swift         # Firestore CRUD operations
│   └── TerritoryValidator.swift      # Check overlaps, validate claims
└── Utilities/
    └── GeoUtils.swift                # Distance calculations, geo helpers
```

## How to Play

1. **Sign In**: Use Apple Sign-In or continue as guest
2. **Start Claiming**: Tap the "Start Claiming" button
3. **Walk in a Circle**: Walk in a circular path (minimum 50m)
4. **Close the Loop**: Return to your starting point (within 15m)
5. **Claim Territory**: If your path is circular enough, the territory is yours!

## Circle Detection Algorithm

The app validates circles based on:
- Minimum path length: 50 meters
- Minimum points: 10 GPS readings
- Loop closure: End point within 15m of start
- Circularity: Standard deviation of distances from centroid < 30%
- Radius bounds: 5m - 500m

## Tech Stack

- **UI**: SwiftUI (iOS 16+)
- **Maps**: MapKit
- **GPS**: Core Location
- **Backend**: Firebase (Auth + Firestore)
- **Architecture**: MVVM pattern

## Testing

### Simulator Testing
Use Xcode's location simulation with a GPX file:
1. Product → Scheme → Edit Scheme
2. Run → Options → Core Location → GPX File

### Device Testing
For real GPS testing, walk outside with your device.

## License

MIT License
