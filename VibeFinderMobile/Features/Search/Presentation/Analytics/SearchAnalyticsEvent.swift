import Foundation

enum SearchAnalyticsEvent {
    static func requested() -> AnalyticsEvent {
        AnalyticsEvent(name: "search_requested")
    }

    static func succeeded(page: SearchPage) -> AnalyticsEvent {
        let resultCount = page.buckets.reduce(0) { count, bucket in
            count + bucket.items.count
        }
        return AnalyticsEvent(
            name: "search_succeeded",
            parameters: ["result_count": .integer(resultCount)]
        )
    }

    static func failed(error: APIError) -> AnalyticsEvent {
        let category: String
        switch error {
        case .server:
            category = "server"
        case .statusCode:
            category = "http_status"
        case .decodingFailed:
            category = "decoding"
        case .transport:
            category = "network"
        case .unknown:
            category = "unknown"
        }
        return AnalyticsEvent(
            name: "search_failed",
            parameters: ["error_category": .string(category)]
        )
    }
}
