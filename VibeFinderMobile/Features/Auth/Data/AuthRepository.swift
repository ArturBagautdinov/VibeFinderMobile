import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let tokenStorage: TokenStorage

    init(apiClient: APIClientProtocol, tokenStorage: TokenStorage) {
        self.apiClient = apiClient
        self.tokenStorage = tokenStorage
    }

    func login(
        login: String,
        password: String,
        completion: @escaping (Result<AuthSession, APIError>) -> Void
    ) {
        apiClient.request(
            .login,
            body: LoginRequest(login: login, password: password)
        ) { [tokenStorage] (result: Result<AuthResponse, APIError>) in
            switch result {
            case let .success(response):
                Self.save(response: response, tokenStorage: tokenStorage, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
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
        let request = RegistrationRequest(
            email: email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            password: password,
            confirmPassword: confirmPassword
        )

        apiClient.request(.register, body: request) { (result: Result<FormSubmissionResponse, APIError>) in
            switch result {
            case let .success(response):
                completion(.success(response.toDomain()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func refreshSession(completion: @escaping (Result<AuthSession, APIError>) -> Void) {
        guard let refreshToken = try? tokenStorage.read()?.refreshToken else {
            completion(.failure(.statusCode(401)))
            return
        }

        apiClient.request(
            .refresh,
            body: RefreshTokenRequest(refreshToken: refreshToken)
        ) { [tokenStorage] (result: Result<AuthResponse, APIError>) in
            switch result {
            case let .success(response):
                Self.save(response: response, tokenStorage: tokenStorage, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let refreshToken = try? tokenStorage.read()?.refreshToken else {
            clearTokens()
            completion(.success(()))
            return
        }

        apiClient.request(
            .logout,
            body: RefreshTokenRequest(refreshToken: refreshToken)
        ) { [weak self] (result: Result<EmptyResponse, APIError>) in
            self?.clearTokens()

            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func resendEmailVerification(
        email: String,
        completion: @escaping (Result<FormSubmission, APIError>) -> Void
    ) {
        apiClient.request(
            .resendEmailVerification,
            body: EmailVerificationResendRequest(email: email)
        ) { (result: Result<FormSubmissionResponse, APIError>) in
            switch result {
            case let .success(response):
                completion(.success(response.toDomain()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func confirmEmailVerification(
        token: String,
        completion: @escaping (Result<EmailVerification, APIError>) -> Void
    ) {
        apiClient.request(.confirmEmailVerification(token: token)) { (result: Result<EmailVerificationResponse, APIError>) in
            switch result {
            case let .success(response):
                completion(.success(response.toDomain()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private static func save(
        response: AuthResponse,
        tokenStorage: TokenStorage,
        completion: @escaping (Result<AuthSession, APIError>) -> Void
    ) {
        do {
            try tokenStorage.save(
                AuthTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            )
            completion(.success(response.toDomain()))
        } catch {
            completion(.failure(.unknown))
        }
    }

    private func clearTokens() {
        try? tokenStorage.clear()
    }
}

private extension AuthResponse {
    func toDomain() -> AuthSession {
        AuthSession(username: username, displayName: displayName, roles: roles)
    }
}

private extension FormSubmissionResponse {
    func toDomain() -> FormSubmission {
        FormSubmission(message: message)
    }
}

private extension EmailVerificationResponse {
    func toDomain() -> EmailVerification {
        EmailVerification(
            success: success,
            status: status,
            type: type,
            email: email,
            userId: userId,
            message: message
        )
    }
}
