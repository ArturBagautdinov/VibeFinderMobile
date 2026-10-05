import Foundation
import Testing
@testable import VibeFinderMobile

@Suite(.serialized)
struct AuthAnalyticsTests {
    @Test
    @MainActor
    func loginTracksRequestAndSuccessWithoutCredentials() async {
        let repository = AuthAnalyticsRepositorySpy()
        repository.loginResult = .success(AuthSession(username: "private-user", displayName: "Private Name"))
        let analytics = AuthAnalyticsSpy()
        let viewModel = LoginViewModel(authRepository: repository, analyticsTracker: analytics)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onAuthenticated = { _ in continuation.resume() }
            viewModel.login(login: "private-user", password: "private-password")
        }

        #expect(analytics.events == [
            AnalyticsEvent(name: "auth_login_requested"),
            AnalyticsEvent(name: "login", parameters: ["method": .string("password")])
        ])
    }

    @Test
    @MainActor
    func loginTracksOnlyFailureCategory() async {
        let repository = AuthAnalyticsRepositorySpy()
        repository.loginResult = .failure(.statusCode(401))
        let analytics = AuthAnalyticsSpy()
        let viewModel = LoginViewModel(authRepository: repository, analyticsTracker: analytics)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if state.errorMessage != nil { continuation.resume() }
            }
            viewModel.login(login: "private-user", password: "private-password")
        }

        #expect(analytics.events == [
            AnalyticsEvent(name: "auth_login_requested"),
            AnalyticsEvent(name: "auth_login_failed", parameters: ["error_category": .string("http_status")])
        ])
    }

    @Test
    @MainActor
    func registrationTracksRequestAndSuccessWithoutPersonalData() async {
        let repository = AuthAnalyticsRepositorySpy()
        repository.registrationResult = .success(FormSubmission(message: "Private server message"))
        let analytics = AuthAnalyticsSpy()
        let viewModel = RegisterViewModel(authRepository: repository, analyticsTracker: analytics)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onRegistered = { _ in continuation.resume() }
            viewModel.register(
                email: "private@example.com",
                username: "private-user",
                firstName: "Private",
                lastName: "Name",
                password: "private-password",
                confirmPassword: "private-password"
            )
        }

        #expect(analytics.events == [
            AnalyticsEvent(name: "auth_registration_requested"),
            AnalyticsEvent(name: "sign_up", parameters: ["method": .string("password")])
        ])
    }

    @Test
    @MainActor
    func registrationTracksOnlyFailureCategory() async {
        let repository = AuthAnalyticsRepositorySpy()
        repository.registrationResult = .failure(.decodingFailed)
        let analytics = AuthAnalyticsSpy()
        let viewModel = RegisterViewModel(authRepository: repository, analyticsTracker: analytics)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if state.errorMessage != nil { continuation.resume() }
            }
            viewModel.register(
                email: "private@example.com",
                username: "private-user",
                firstName: "Private",
                lastName: "Name",
                password: "private-password",
                confirmPassword: "private-password"
            )
        }

        #expect(analytics.events == [
            AnalyticsEvent(name: "auth_registration_requested"),
            AnalyticsEvent(
                name: "auth_registration_failed",
                parameters: ["error_category": .string("decoding")]
            )
        ])
    }

    @Test
    @MainActor
    func invalidAuthFormsDoNotTrackRequests() {
        let repository = AuthAnalyticsRepositorySpy()
        let analytics = AuthAnalyticsSpy()
        LoginViewModel(authRepository: repository, analyticsTracker: analytics)
            .login(login: " ", password: "")
        RegisterViewModel(authRepository: repository, analyticsTracker: analytics)
            .register(
                email: "private@example.com",
                username: "private-user",
                firstName: "Private",
                lastName: "Name",
                password: "one",
                confirmPassword: "two"
            )

        #expect(analytics.events.isEmpty)
        #expect(repository.loginCallCount == 0)
        #expect(repository.registrationCallCount == 0)
    }

    @Test
    @MainActor
    func eventFactoriesUseSharedErrorCategories() {
        #expect(AuthAnalyticsEvent.registrationFailed(error: .decodingFailed) == AnalyticsEvent(
            name: "auth_registration_failed",
            parameters: ["error_category": .string("decoding")]
        ))
        #expect(ProfileLogoutAnalyticsEvent.failed(error: .unknown) == AnalyticsEvent(
            name: "auth_logout_failed",
            parameters: ["error_category": .string("unknown")]
        ))
        #expect(SearchAnalyticsEvent.failed(error: .statusCode(503)).parameters["error_category"] == .string("http_status"))
        #expect(ProfileEditAnalyticsEvent.saveFailed(error: .decodingFailed).parameters["reason"] == .string("decoding"))
    }
}

private final class AuthAnalyticsRepositorySpy: AuthRepositoryProtocol {
    var loginResult: Result<AuthSession, APIError> = .failure(.unknown)
    var registrationResult: Result<FormSubmission, APIError> = .failure(.unknown)
    private(set) var loginCallCount = 0
    private(set) var registrationCallCount = 0

    func login(login: String, password: String, completion: @escaping (Result<AuthSession, APIError>) -> Void) {
        loginCallCount += 1
        completion(loginResult)
    }

    func register(
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        password: String,
        confirmPassword: String,
        completion: @escaping (Result<FormSubmission, APIError>) -> Void
    ) {
        registrationCallCount += 1
        completion(registrationResult)
    }

    func refreshSession(completion: @escaping (Result<AuthSession, APIError>) -> Void) {}
    func logout(completion: @escaping (Result<Void, APIError>) -> Void) {}
    func resendEmailVerification(email: String, completion: @escaping (Result<FormSubmission, APIError>) -> Void) {}
    func confirmEmailVerification(token: String, completion: @escaping (Result<EmailVerification, APIError>) -> Void) {}
}

private final class AuthAnalyticsSpy: AnalyticsTrackerProtocol {
    private(set) var events: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        events.append(event)
    }
}
