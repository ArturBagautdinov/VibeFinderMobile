import Foundation

final class RegisterViewModel {
    struct State {
        let isLoading: Bool
        let errorMessage: String?
    }

    private let authRepository: AuthRepositoryProtocol

    var onStateChange: ((State) -> Void)?
    var onRegistered: ((String) -> Void)?

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func register(
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        password: String,
        confirmPassword: String
    ) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !normalizedEmail.isEmpty,
            !normalizedUsername.isEmpty,
            !normalizedFirstName.isEmpty,
            !normalizedLastName.isEmpty,
            !password.isEmpty,
            !confirmPassword.isEmpty
        else {
            onStateChange?(State(isLoading: false, errorMessage: L10n.Auth.Validation.requiredFields))
            return
        }

        guard password == confirmPassword else {
            onStateChange?(State(isLoading: false, errorMessage: L10n.Auth.Validation.passwordMismatch))
            return
        }

        onStateChange?(State(isLoading: true, errorMessage: nil))
        authRepository.register(
            email: normalizedEmail,
            username: normalizedUsername,
            firstName: normalizedFirstName,
            lastName: normalizedLastName,
            password: password,
            confirmPassword: confirmPassword
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.onStateChange?(State(isLoading: false, errorMessage: nil))
                switch result {
                case let .success(submission):
                    self?.onRegistered?(submission.message)
                case let .failure(error):
                    self?.onStateChange?(State(isLoading: false, errorMessage: error.userMessage))
                }
            }
        }
    }
}
