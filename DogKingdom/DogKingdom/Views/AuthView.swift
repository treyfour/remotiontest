import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .green.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Spacer()

                // Logo and title
                VStack(spacing: 16) {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)

                    Text("Dog Kingdom")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Claim your territory")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // Features list
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "figure.walk", text: "Walk in circles to claim land")
                    FeatureRow(icon: "map.fill", text: "See territories on the map")
                    FeatureRow(icon: "person.2.fill", text: "Compete with other players")
                }
                .padding(.horizontal, 40)

                Spacer()

                // Sign in buttons
                VStack(spacing: 16) {
                    SignInWithAppleButton(
                        onRequest: { request in
                            let appleRequest = authViewModel.prepareSignInWithApple()
                            request.requestedScopes = appleRequest.requestedScopes
                            request.nonce = appleRequest.nonce
                        },
                        onCompletion: { result in
                            authViewModel.handleSignInWithApple(result: result)
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)

                    #if DEBUG
                    // Anonymous sign in for testing
                    Button {
                        authViewModel.signInAnonymously()
                    } label: {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                            Text("Continue as Guest")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    #endif
                }

                // Error message
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                }

                // Loading indicator
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }

                Spacer()

                // Terms
                Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40)

            Text(text)
                .font(.body)
                .foregroundColor(.white)

            Spacer()
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
