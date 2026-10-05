import Foundation

final class LoginViewModel {
    struct State {
        let isLoading: Bool
        let errorMessage: String?
    }

    private let authRepository: AuthRepositoryProtocol
    private let analyticsTracker: AnalyticsTrackerProtocol

    var onStateChange: ((State) -> Void)?
    var onAuthenticated: ((AuthSession) -> Void)?

    init(authRepository: AuthRepositoryProtocol, analyticsTracker: AnalyticsTrackerProtocol) {
        self.authRepository = authRepository
        self.analyticsTracker = analyticsTracker
    }

    func login(login: String, password: String) {
        let normalizedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedLogin.isEmpty, !password.isEmpty else {
            onStateChange?(State(isLoading: false, errorMessage: L10n.Auth.Validation.requiredFields))
            return
        }

        analyticsTracker.track(AuthAnalyticsEvent.loginRequested())
        onStateChange?(State(isLoading: true, errorMessage: nil))
        authRepository.login(login: normalizedLogin, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.onStateChange?(State(isLoading: false, errorMessage: nil))
                switch result {
                case let .success(session):
                    self.analyticsTracker.track(AuthAnalyticsEvent.loginSucceeded())
                    self.onAuthenticated?(session)
                case let .failure(error):
                    self.analyticsTracker.track(AuthAnalyticsEvent.loginFailed(error: error))
                    self.onStateChange?(State(isLoading: false, errorMessage: error.userMessage))
                }
            }
        }
    }
}
