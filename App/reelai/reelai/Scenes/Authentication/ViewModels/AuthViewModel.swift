import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var error: AuthError?
    @Published var isAuthenticated = false
    @Published var currentUser: FirestoreUser?
    @Published var resendCooldown: Int = 0
    @Published var successMessage: String?

    // MARK: - Private Properties
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    private var resendTimer: Timer?
    private var backgroundObserver: NSObjectProtocol?

    // MARK: - Initialization
    init() {
        setupAuthStateListener()
        setupBackgroundObserver()
    }

    deinit {
        resendTimer?.invalidate()
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Public Methods

    /// Signs up a new user with email and password
    func signUp() async {
        isLoading = true
        error = nil

        do {
            // Validate input first
            try GlobalValidator.validateSignUp(
                email: email, password: password, confirmPassword: confirmPassword)

            // If validation passes, proceed with sign up
            currentUser = try await authService.signUp(
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
            isAuthenticated = true
        } catch {
            self.error =
                error as? AuthError
                ?? .unknown(NSLocalizedString("auth.error.generic", comment: ""))
        }

        isLoading = false
    }

    /// Signs in an existing user with email and password
    func signIn() async {
        isLoading = true
        error = nil

        do {
            // Validate input first
            try GlobalValidator.validateSignIn(email: email, password: password)

            // If validation passes, proceed with sign in
            currentUser = try await authService.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            self.error =
                error as? AuthError
                ?? .unknown(NSLocalizedString("auth.error.generic", comment: ""))
        }

        isLoading = false
    }

    /// Signs out the current user
    func signOut() async {
        isLoading = true
        error = nil

        do {
            try await authService.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            self.error =
                error as? AuthError
                ?? .unknown(NSLocalizedString("auth.error.generic", comment: ""))
        }

        isLoading = false
    }

    /// Sends a password reset email
    func sendPasswordReset() async {
        isLoading = true
        error = nil

        do {
            try await authService.sendPasswordReset(to: email)
        } catch {
            self.error =
                error as? AuthError
                ?? .unknown(NSLocalizedString("auth.error.generic", comment: ""))
        }

        isLoading = false
    }

    /// Signs in a user with Google
    func signInWithGoogle() async {
        isLoading = true
        error = nil

        do {
            currentUser = try await authService.signInWithGoogle()
            isAuthenticated = true
        } catch {
            self.error =
                error as? AuthError
                ?? .unknown(NSLocalizedString("auth.error.generic", comment: ""))
        }

        isLoading = false
    }

    /// Resends the email verification to the current user
    func resendEmailVerification() async {
        guard resendCooldown == 0 else { return }

        isLoading = true
        error = nil

        do {
            try await authService.resendEmailVerification()
            startResendCooldown()
            successMessage = NSLocalizedString("auth.verify.email.sent", comment: "")

            // Auto-dismiss success message after 3 seconds
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                successMessage = nil
            }
        } catch {
            self.error =
                error as? AuthError
                ?? .unknown(NSLocalizedString("auth.error.generic", comment: ""))
        }

        isLoading = false
    }

    /// Refreshes the current user's email verification status
    func refreshEmailVerificationStatus() async {
        error = nil

        do {
            let updatedUser = try await authService.refreshEmailVerificationStatus()
            currentUser = updatedUser

            if updatedUser.isEmailVerified {
                successMessage = NSLocalizedString("auth.verify.email.verified", comment: "")
                // Auto-dismiss success message after 3 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    successMessage = nil
                }
            }
        } catch {
            self.error =
                error as? AuthError
                ?? .unknown(NSLocalizedString("auth.error.generic", comment: ""))
        }
    }

    // MARK: - Validation Methods

    /// Checks if the sign-up form is valid
    var isSignUpFormValid: Bool {
        GlobalValidator.isSignUpFormValid(
            email: email, password: password, confirmPassword: confirmPassword)
    }

    /// Checks if the sign-in form is valid
    var isSignInFormValid: Bool {
        GlobalValidator.isSignInFormValid(email: email, password: password)
    }

    // MARK: - Private Methods

    private func setupAuthStateListener() {
        Task {
            if authService.isAuthenticated {
                do {
                    currentUser = try await authService.getCurrentUser()
                    isAuthenticated = true
                } catch {
                    self.error =
                        error as? AuthError
                        ?? .unknown(NSLocalizedString("auth.error.generic", comment: ""))
                }
            }
        }
    }

    private func setupBackgroundObserver() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.refreshEmailVerificationStatus()
            }
        }
    }

    private func startResendCooldown() {
        resendCooldown = 60  // 60 seconds cooldown
        resendTimer?.invalidate()

        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if self.resendCooldown > 0 {
                self.resendCooldown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
