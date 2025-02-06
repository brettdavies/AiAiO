import SwiftUI

struct EmailVerificationBannerView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isRefreshing = false
    @State private var showingInstructions = false

    var body: some View {
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
                            if viewModel.resendCooldown > 0 {
                                Text(
                                    String(
                                        format: NSLocalizedString(
                                            "auth.verify.email.resend.cooldown", comment: ""),
                                        viewModel.resendCooldown)
                                )
                                .font(.footnote)
                            } else {
                                Text(NSLocalizedString("auth.verify.email.resend", comment: ""))
                                    .font(.footnote)
                            }
                        }
                        .disabled(viewModel.isLoading || viewModel.resendCooldown > 0)

                        Spacer()

                        Button {
                            Task {
                                isRefreshing = true
                                await viewModel.refreshEmailVerificationStatus()
                                isRefreshing = false
                            }
                        } label: {
                            HStack {
                                if isRefreshing {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                Text(NSLocalizedString("common.refresh", comment: ""))
                                    .font(.footnote)
                            }
                        }
                        .disabled(viewModel.isLoading || isRefreshing)
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
            if let successMessage = viewModel.successMessage {
                Text(successMessage)
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
        .animation(.default, value: viewModel.successMessage)
        .animation(.default, value: viewModel.error)
        .animation(.default, value: showingInstructions)
    }
}

#Preview {
    EmailVerificationBannerView(viewModel: AuthViewModel())
}
