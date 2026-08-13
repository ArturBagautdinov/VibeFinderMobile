import Alamofire
import Foundation

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: HTTPHeaders

    init(
        path: String,
        method: HTTPMethod,
        headers: HTTPHeaders = [.accept("application/json"), .contentType("application/json")]
    ) {
        self.path = path
        self.method = method
        self.headers = headers
    }
}

extension APIEndpoint {
    static let login = APIEndpoint(path: "api/auth/login", method: .post)
    static let register = APIEndpoint(path: "api/auth/register", method: .post)
}
