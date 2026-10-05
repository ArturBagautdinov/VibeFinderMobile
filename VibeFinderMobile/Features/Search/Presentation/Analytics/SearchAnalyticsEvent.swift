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
        return AnalyticsEvent(
            name: "search_failed",
            parameters: [
                "error_category": .string(SearchAnalyticsErrorCategory(error: error).rawValue)
            ]
        )
    }
}
