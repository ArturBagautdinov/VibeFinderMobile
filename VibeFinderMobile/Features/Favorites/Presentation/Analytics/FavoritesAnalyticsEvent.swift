enum FavoritesAnalyticsEvent {
    static func loadRequested() -> AnalyticsEvent {
        AnalyticsEvent(name: "favorites_list_requested")
    }

    static func loadSucceeded(count: Int) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "favorites_list_succeeded",
            parameters: ["result_count": .integer(count)]
        )
    }

    static func loadFailed(error: APIError) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "favorites_list_failed",
            parameters: [
                "error_category": .string(APIErrorAnalyticsCategory(error: error).rawValue)
            ]
        )
    }
}
