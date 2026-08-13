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
                do {
                    try tokenStorage.save(
                        AuthTokens(
                            accessToken: response.accessToken,
                            refreshToken: response.refreshToken
                        )
                    )
                    completion(.success(AuthSession(username: response.username, displayName: response.displayName)))
                } catch {
                    completion(.failure(.unknown))
                }
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
                completion(.success(FormSubmission(message: response.message)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
