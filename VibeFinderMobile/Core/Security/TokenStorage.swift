import Foundation

protocol TokenStorage {
    func save(_ tokens: AuthTokens) throws
    func read() throws -> AuthTokens?
    func clear() throws
}

struct AuthTokens {
    let accessToken: String
    let refreshToken: String
}

final class KeychainTokenStorage: TokenStorage {
    private enum Key {
        static let accessToken = "auth.accessToken"
        static let refreshToken = "auth.refreshToken"
    }

    private let keychainStorage: KeychainStoring

    init(keychainStorage: KeychainStoring) {
        self.keychainStorage = keychainStorage
    }

    func save(_ tokens: AuthTokens) throws {
        try keychainStorage.save(tokens.accessToken, for: Key.accessToken)
        try keychainStorage.save(tokens.refreshToken, for: Key.refreshToken)
    }

    func read() throws -> AuthTokens? {
        guard
            let accessToken = try keychainStorage.read(Key.accessToken),
            let refreshToken = try keychainStorage.read(Key.refreshToken)
        else {
            return nil
        }

        return AuthTokens(accessToken: accessToken, refreshToken: refreshToken)
    }

    func clear() throws {
        try keychainStorage.delete(Key.accessToken)
        try keychainStorage.delete(Key.refreshToken)
    }
}
