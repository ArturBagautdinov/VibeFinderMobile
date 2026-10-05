enum ProfileLogoutAnalyticsEvent {
    static func requested() -> AnalyticsEvent {
        AnalyticsEvent(name: "auth_logout_requested")
    }

    static func succeeded() -> AnalyticsEvent {
        AnalyticsEvent(name: "auth_logout_succeeded")
    }

    static func failed(error: APIError) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "auth_logout_failed",
            parameters: ["error_category": .string(APIErrorAnalyticsCategory(error: error).rawValue)]
        )
    }
}
