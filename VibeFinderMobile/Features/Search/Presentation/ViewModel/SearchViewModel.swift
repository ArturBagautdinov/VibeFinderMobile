import Foundation

final class SearchViewModel {
    struct State {
        let username: String
        let suggestions: [String]
        let recentVibes: [RecentVibe]
        let isLoading: Bool
        let errorMessage: String?
    }

    struct RecentVibe {
        let title: String
        let subtitle: String
    }

    private let searchRepository: SearchRepositoryProtocol
    private(set) var state: State

    var onStateChange: ((State) -> Void)?
    var onResultsReady: ((SearchPage) -> Void)?

    init(username: String, searchRepository: SearchRepositoryProtocol) {
        self.searchRepository = searchRepository
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
            ],
            isLoading: false,
            errorMessage: nil
        )
    }

    func search(query: String) {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else {
            update(errorMessage: L10n.Search.Validation.emptyQuery)
            return
        }

        update(isLoading: true, errorMessage: nil)
        searchRepository.search(query: normalizedQuery) { [weak self] result in
            self?.completeOnMain {
                switch result {
                case let .success(page):
                    self?.update(isLoading: false, errorMessage: nil)
                    self?.onResultsReady?(page)
                case let .failure(error):
                    self?.update(isLoading: false, errorMessage: error.userMessage)
                }
            }
        }
    }

    private func update(
        isLoading: Bool? = nil,
        errorMessage: String? = nil
    ) {
        state = State(
            username: state.username,
            suggestions: state.suggestions,
            recentVibes: state.recentVibes,
            isLoading: isLoading ?? state.isLoading,
            errorMessage: errorMessage
        )
        onStateChange?(state)
    }

    private func completeOnMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}
