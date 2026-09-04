
import Foundation

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
