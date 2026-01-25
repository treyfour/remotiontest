import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class AuthViewModel: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentNonce: String?
    private let firebaseService = FirebaseService.shared

    override init() {
        super.init()
        checkAuthState()
    }

    private func checkAuthState() {
        if let firebaseUser = Auth.auth().currentUser {
            isAuthenticated = true
            Task {
                await loadUserProfile(firebaseUser)
            }
        }
    }

    // MARK: - Apple Sign In

    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            handleAppleAuthorization(authorization)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    func prepareSignInWithApple() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        return request
    }

    private func handleAppleAuthorization(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            errorMessage = "Unable to fetch identity token"
            return
        }

        isLoading = true

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        Auth.auth().signIn(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                if let firebaseUser = result?.user {
                    self?.isAuthenticated = true
                    self?.createOrUpdateUser(firebaseUser, appleCredential: appleIDCredential)
                }
            }
        }
    }

    private func createOrUpdateUser(_ firebaseUser: FirebaseAuth.User, appleCredential: ASAuthorizationAppleIDCredential?) {
        Task {
            do {
                // Check if user exists
                if let existingUser = try await firebaseService.getUser(firebaseUser.uid) {
                    await MainActor.run {
                        self.currentUser = existingUser
                    }
                } else {
                    // Create new user
                    var displayName = firebaseUser.displayName ?? "Dog Walker"

                    // Try to get name from Apple credential
                    if let fullName = appleCredential?.fullName {
                        let givenName = fullName.givenName ?? ""
                        let familyName = fullName.familyName ?? ""
                        if !givenName.isEmpty || !familyName.isEmpty {
                            displayName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
                        }
                    }

                    let newUser = AppUser(
                        id: firebaseUser.uid,
                        displayName: displayName,
                        email: firebaseUser.email
                    )

                    try await firebaseService.saveUser(newUser)

                    await MainActor.run {
                        self.currentUser = newUser
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadUserProfile(_ firebaseUser: FirebaseAuth.User) async {
        do {
            if let user = try await firebaseService.getUser(firebaseUser.uid) {
                await MainActor.run {
                    self.currentUser = user
                }
            } else {
                // User doesn't exist in Firestore, create profile
                let newUser = AppUser(
                    id: firebaseUser.uid,
                    displayName: firebaseUser.displayName ?? "Dog Walker",
                    email: firebaseUser.email
                )
                try await firebaseService.saveUser(newUser)
                await MainActor.run {
                    self.currentUser = newUser
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Anonymous Sign In (for testing)

    func signInAnonymously() {
        isLoading = true

        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                if let firebaseUser = result?.user {
                    self?.isAuthenticated = true
                    self?.createOrUpdateUser(firebaseUser, appleCredential: nil)
                }
            }
        }
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
