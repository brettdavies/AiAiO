// System imports
import SwiftUI

/// A view that displays a banner for email verification status and actions
public struct EmailVerificationBannerView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showingInstructions = false

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 8) {
            if let user = viewModel.currentUser, !user.isEmailVerified {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text(NSLocalizedString("auth.verify.email.message", comment: ""))
                            .font(.subheadline)
                        Spacer()
                    }

                    Text(NSLocalizedString("auth.verify.email.timing.info", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(NSLocalizedString("auth.verify.email.check.spam", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if showingInstructions {
                        Text(NSLocalizedString("auth.verify.email.instructions", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }

                    HStack {
                        Button {
                            Task {
                                await viewModel.resendEmailVerification()
                            }
                        } label: {
                            Text(NSLocalizedString("auth.verify.email.resend", comment: ""))
                                .font(.footnote)
                        }
                        .disabled(viewModel.isLoading)

                        Spacer()

                        Button {
                            Task {
                                await viewModel.refreshEmailVerificationStatus()
                            }
                        } label: {
                            HStack {
                                if viewModel.isRefreshing {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                Text(NSLocalizedString("common.refresh", comment: ""))
                                    .font(.footnote)
                            }
                        }
                        .disabled(viewModel.isLoading || viewModel.isRefreshing)
                    }

                    Button {
                        withAnimation {
                            showingInstructions.toggle()
                        }
                    } label: {
                        Text(
                            showingInstructions
                                ? NSLocalizedString(
                                    "auth.verify.email.hide_instructions", comment: "")
                                : NSLocalizedString(
                                    "auth.verify.email.show_instructions", comment: "")
                        )
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            // Success message
            if !viewModel.successMessage.isEmpty {
                Text(viewModel.successMessage)
                    .font(.footnote)
                    .foregroundColor(.green)
                    .padding(.vertical, 4)
            }

            // Error message
            if let error = viewModel.error {
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.vertical, 4)
            }
        }
        .padding(.horizontal)
        .animation(.default, value: !viewModel.successMessage.isEmpty)
        .animation(.default, value: viewModel.error != nil)
        .animation(.default, value: showingInstructions)
    }
}

// #Preview("Unverified Email") {
//     EmailVerificationBannerView(
//         viewModel: AuthViewModel(
//             authService: MockAuthService(state: .authenticated(AuthPreviewState.unverifiedUser)),
//             environment: .development
//         )
//     )
// }

// #Preview("Verified Email") {
//     EmailVerificationBannerView(
//         viewModel: AuthViewModel(
//             authService: MockAuthService(state: .authenticated(AuthPreviewState.previewUser)),
//             environment: .development
//         )
//     )
// }

// #Preview("Loading") {
//     EmailVerificationBannerView(
//         viewModel: AuthViewModel(
//             authService: MockAuthService(state: .loading),
//             environment: .development
//         )
//     )
// }

// #Preview("Error") {
//     EmailVerificationBannerView(
//         viewModel: AuthViewModel(
//             authService: MockAuthService(
//                 state: .error(AuthError.invalidEmail("Invalid email"))
//             ),
//             environment: .development
//         )
//     )
// }
