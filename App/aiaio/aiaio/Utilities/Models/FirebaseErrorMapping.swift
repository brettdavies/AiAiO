import Foundation
import FirebaseAuth

func mapFirebaseError(_ error: Error) -> GlobalError {
    let nsError = error as NSError
    let mappedError: GlobalError

    if nsError.code == AuthErrorCode.invalidEmail.rawValue {
        mappedError = .invalidEmail
    } else if nsError.code == AuthErrorCode.weakPassword.rawValue {
        mappedError = .weakPassword
    } else {
        mappedError = .unknown(nsError.localizedDescription)
    }

    UnifiedLogger.debug("Mapped Firebase error: \(nsError.code) to GlobalError: \(mappedError)", context: "Error")
    return mappedError
}
