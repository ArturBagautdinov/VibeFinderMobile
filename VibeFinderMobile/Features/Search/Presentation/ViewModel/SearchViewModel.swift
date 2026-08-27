import Foundation

final class SearchViewModel {
    struct State {
        let username: String
        let suggestions: [String]
        let recentVibes: [RecentVibe]
    }

    struct RecentVibe {
        let title: String
        let subtitle: String
    }

    let state: State

    init(username: String) {
        self.state = State(
            username: username,
            suggestions: [
                L10n.Search.Suggestion.cozyEvening,
                L10n.Search.Suggestion.darkMystery,
                L10n.Search.Suggestion.beautifulScifi,
                L10n.Search.Suggestion.slowSunday
            ],
            recentVibes: [
                RecentVibe(
                    title: L10n.Search.Recent.rainyEveningTitle,
                    subtitle: L10n.Search.Recent.rainyEveningSubtitle
                ),
                RecentVibe(
                    title: L10n.Search.Recent.weekendGameTitle,
                    subtitle: L10n.Search.Recent.weekendGameSubtitle
                ),
                RecentVibe(
                    title: L10n.Search.Recent.detectiveSeriesTitle,
                    subtitle: L10n.Search.Recent.detectiveSeriesSubtitle
                )
            ]
        )
    }
}
