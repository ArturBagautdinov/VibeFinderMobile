enum APIErrorAnalyticsCategory: String {
    case server
    case httpStatus = "http_status"
    case decoding
    case network
    case unknown

    init(error: APIError) {
        switch error {
        case .server:
            self = .server
        case .statusCode:
            self = .httpStatus
        case .decodingFailed:
            self = .decoding
        case .transport:
            self = .network
        case .unknown:
            self = .unknown
        }
    }
}
