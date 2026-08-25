import Foundation

final class LoginViewModel {
    struct State {
        let isLoading: Bool
        let errorMessage: String?
    }

    private let authRepository: AuthRepositoryProtocol

    var onStateChange: ((State) -> Void)?
    var onAuthenticated: ((AuthSession) -> Void)?

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func login(login: String, password: String) {
        let normalizedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedLogin.isEmpty, !password.isEmpty else {
            onStateChange?(State(isLoading: false, errorMessage: L10n.Auth.Validation.requiredFields))
            return
        }

        onStateChange?(State(isLoading: true, errorMessage: nil))
        authRepository.login(login: normalizedLogin, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.onStateChange?(State(isLoading: false, errorMessage: nil))
                switch result {
                case let .success(session):
                    self?.onAuthenticated?(session)
                case let .failure(error):
                    self?.onStateChange?(State(isLoading: false, errorMessage: error.userMessage))
                }
            }
        }
    }
}
