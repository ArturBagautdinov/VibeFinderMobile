import Foundation

struct LoginRequest: Encodable {
    let login: String
    let password: String
}

struct RegistrationRequest: Encodable {
    let email: String
    let username: String
    let firstName: String
    let lastName: String
    let password: String
    let confirmPassword: String
}

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresAt: String
    let refreshExpiresAt: String
    let username: String
    let displayName: String
    let roles: [String]
}

struct FormSubmissionResponse: Decodable {
    let message: String
    let redirectUrl: String?
    let fieldErrors: [String: String]

    private enum CodingKeys: String, CodingKey {
        case message
        case redirectUrl
        case fieldErrors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        redirectUrl = try container.decodeIfPresent(String.self, forKey: .redirectUrl)
        fieldErrors = try container.decodeIfPresent([String: String].self, forKey: .fieldErrors) ?? [:]
    }
}
