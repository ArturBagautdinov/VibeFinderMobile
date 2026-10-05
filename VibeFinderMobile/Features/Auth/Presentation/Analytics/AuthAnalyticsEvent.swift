enum AuthAnalyticsEvent {
    static func loginRequested() -> AnalyticsEvent {
        AnalyticsEvent(name: "auth_login_requested")
    }

    static func loginSucceeded() -> AnalyticsEvent {
        AnalyticsEvent(name: "login", parameters: ["method": .string("password")])
    }

    static func loginFailed(error: APIError) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "auth_login_failed",
            parameters: ["error_category": .string(APIErrorAnalyticsCategory(error: error).rawValue)]
        )
    }

    static func registrationRequested() -> AnalyticsEvent {
        AnalyticsEvent(name: "auth_registration_requested")
    }

    static func registrationSucceeded() -> AnalyticsEvent {
        AnalyticsEvent(name: "sign_up", parameters: ["method": .string("password")])
    }

    static func registrationFailed(error: APIError) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "auth_registration_failed",
            parameters: ["error_category": .string(APIErrorAnalyticsCategory(error: error).rawValue)]
        )
    }
}
