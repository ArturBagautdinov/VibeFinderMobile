import Alamofire
import Foundation

enum APIError: Error {
    case server(APIErrorResponse)
    case statusCode(Int)
    case decodingFailed
    case transport(AFError)
    case unknown

    var userMessage: String {
        switch self {
        case let .server(response):
            if response.details.isEmpty {
                return response.message
            }
            return ([response.message] + response.details).joined(separator: "\n")
        case let .statusCode(code):
            return L10n.Error.httpStatus(code)
        case .decodingFailed:
            return L10n.Error.decoding
        case .transport:
            return L10n.Error.network
        case .unknown:
            return L10n.Error.unknown
        }
    }
}

struct APIErrorResponse: Decodable {
    let timestamp: String?
    let status: Int
    let errorCode: String?
    let message: String
    let details: [String]

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case status
        case errorCode
        case message
        case details
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
        status = try container.decode(Int.self, forKey: .status)
        errorCode = try container.decodeIfPresent(String.self, forKey: .errorCode)
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? L10n.Error.unknown
        details = try container.decodeIfPresent([String].self, forKey: .details) ?? []
    }
}
