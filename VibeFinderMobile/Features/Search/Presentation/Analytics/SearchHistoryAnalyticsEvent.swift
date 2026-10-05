enum SearchHistorySource: String {
    case recent
    case full
}

enum SearchHistoryAnalyticsEvent {
    static func openRequested(source: SearchHistorySource) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "search_history_open_requested",
            parameters: ["source": .string(source.rawValue)]
        )
    }

    static func openSucceeded(source: SearchHistorySource) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "search_history_open_succeeded",
            parameters: ["source": .string(source.rawValue)]
        )
    }

    static func openFailed(source: SearchHistorySource, error: APIError) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "search_history_open_failed",
            parameters: [
                "source": .string(source.rawValue),
                "error_category": .string(APIErrorAnalyticsCategory(error: error).rawValue)
            ]
        )
    }
}
