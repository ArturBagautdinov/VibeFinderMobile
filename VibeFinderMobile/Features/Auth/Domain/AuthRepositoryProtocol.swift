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

    func refreshSession(completion: @escaping (Result<AuthSession, APIError>) -> Void)

    func logout(completion: @escaping (Result<Void, APIError>) -> Void)

    func resendEmailVerification(
        email: String,
        completion: @escaping (Result<FormSubmission, APIError>) -> Void
    )

    func confirmEmailVerification(
        token: String,
        completion: @escaping (Result<EmailVerification, APIError>) -> Void
    )
}

struct AuthSession {
    let username: String
    let displayName: String
    let roles: [String]

    init(username: String, displayName: String, roles: [String] = []) {
        self.username = username
        self.displayName = displayName
        self.roles = roles
    }
}

struct FormSubmission {
    let message: String
}

struct EmailVerification {
    let success: Bool
    let status: String
    let type: String
    let email: String
    let userId: Int
    let message: String
}
