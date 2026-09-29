import Alamofire
import Foundation

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: HTTPHeaders
    let queryItems: [URLQueryItem]
    let requiresAuthorization: Bool

    init(
        path: String,
        method: HTTPMethod,
        headers: HTTPHeaders = [.accept("application/json"), .contentType("application/json")],
        queryItems: [URLQueryItem] = [],
        requiresAuthorization: Bool = false
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.requiresAuthorization = requiresAuthorization
    }
}

extension APIEndpoint {
    static let login = APIEndpoint(path: "api/auth/login", method: .post)
    static let refresh = APIEndpoint(path: "api/auth/refresh", method: .post)
    static let logout = APIEndpoint(path: "api/auth/logout", method: .post)
    static let register = APIEndpoint(path: "api/auth/register", method: .post)
    static let resendEmailVerification = APIEndpoint(path: "api/auth/email-verification/resend", method: .post)
    static let startSearch = APIEndpoint(path: "api/search", method: .post, requiresAuthorization: true)
    static let searchHistory = APIEndpoint(
        path: "api/search/history",
        method: .get,
        headers: [.accept("application/json")],
        requiresAuthorization: true
    )
    static let clearSearchHistory = APIEndpoint(
        path: "api/search/history",
        method: .delete,
        headers: [.accept("application/json")],
        requiresAuthorization: true
    )
    
    static let profile = APIEndpoint(
        path: "api/profile",
        method: .get,
        headers: [.accept("application/json")],
        requiresAuthorization: true
    )

    static let updateProfile = APIEndpoint(
        path: "api/profile",
        method: .put,
        requiresAuthorization: true
    )

    static func searchPage(id: Int) -> APIEndpoint {
        APIEndpoint(path: "api/search/\(id)", method: .get, headers: [.accept("application/json")], requiresAuthorization: true)
    }

    static func deleteSearchHistoryItem(id: Int) -> APIEndpoint {
        APIEndpoint(path: "api/search/\(id)", method: .delete, headers: [.accept("application/json")], requiresAuthorization: true)
    }

    static func confirmEmailVerification(token: String) -> APIEndpoint {
        APIEndpoint(
            path: "api/auth/email-verification/confirm",
            method: .get,
            headers: [.accept("application/json")],
            queryItems: [URLQueryItem(name: "token", value: token)]
        )
    }
}
