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
