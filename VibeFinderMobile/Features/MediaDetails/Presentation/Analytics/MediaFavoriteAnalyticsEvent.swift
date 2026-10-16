enum MediaFavoriteAnalyticsEvent {
    static func requested(isFavorite: Bool) -> AnalyticsEvent {
        AnalyticsEvent(name: "favorite_change_requested", parameters: ["action": action(isFavorite)])
    }

    static func succeeded(isFavorite: Bool) -> AnalyticsEvent {
        AnalyticsEvent(name: "favorite_change_succeeded", parameters: ["action": action(isFavorite)])
    }

    static func failed(isFavorite: Bool, error: APIError) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "favorite_change_failed",
            parameters: [
                "action": action(isFavorite),
                "error_category": .string(APIErrorAnalyticsCategory(error: error).rawValue)
            ]
        )
    }

    private static func action(_ isFavorite: Bool) -> AnalyticsParameterValue {
        .string(isFavorite ? "add" : "remove")
    }
}
