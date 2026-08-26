import Foundation

struct AppEnvironment {
    let baseURL: URL

    static let current = AppEnvironment(
        baseURL: URL(string: "http://localhost:8081")!
    )
}
