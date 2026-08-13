import Foundation

protocol AuthRepositoryProtocol {
    func login(
        login: String,
        password: String,
        completion: @escaping (Result<AuthSession, APIError>) -> Void
    )

    func register(
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        password: String,
        confirmPassword: String,
        completion: @escaping (Result<FormSubmission, APIError>) -> Void
    )
}

struct AuthSession {
    let username: String
    let displayName: String
}

struct FormSubmission {
    let message: String
}
