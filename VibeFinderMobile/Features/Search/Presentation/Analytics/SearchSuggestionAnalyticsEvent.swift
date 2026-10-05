enum SearchSuggestionAnalyticsEvent {
    static func selected(kind: SearchSuggestion.Kind) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "search_suggestion_selected",
            parameters: ["kind": .string(kind.analyticsValue)]
        )
    }

    static func customAdded() -> AnalyticsEvent {
        AnalyticsEvent(
            name: "search_suggestion_added",
            parameters: ["kind": .string(SearchSuggestion.Kind.custom.analyticsValue)]
        )
    }

    static func deleted(kind: SearchSuggestion.Kind) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "search_suggestion_deleted",
            parameters: ["kind": .string(kind.analyticsValue)]
        )
    }

    static func defaultsRestored() -> AnalyticsEvent {
        AnalyticsEvent(name: "search_suggestions_defaults_restored")
    }
}

private extension SearchSuggestion.Kind {
    var analyticsValue: String {
        switch self {
        case .builtIn:
            return "built_in"
        case .custom:
            return "custom"
        }
    }
}
