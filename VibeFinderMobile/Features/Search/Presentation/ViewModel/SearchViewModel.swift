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
    private let suggestionsStore: SearchSuggestionsStoreProtocol
    private var suggestionModels: [SearchSuggestion]
    private(set) var state: State

    var onStateChange: ((State) -> Void)?
    var onResultsReady: ((SearchPage) -> Void)?

    init(
        username: String,
        searchRepository: SearchRepositoryProtocol,
        suggestionsStore: SearchSuggestionsStoreProtocol
    ) {
        self.searchRepository = searchRepository
        self.suggestionsStore = suggestionsStore
        let suggestionModels = suggestionsStore.loadSuggestions()
        self.suggestionModels = suggestionModels
        self.state = State(
            username: username,
            suggestions: Self.makeDisplayTitles(from: suggestionModels),
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

    func addCustomSuggestion(_ suggestion: String) {
        let normalizedSuggestion = suggestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedSuggestion.isEmpty else {
            return
        }

        guard !state.suggestions.contains(where: { $0.caseInsensitiveCompare(normalizedSuggestion) == .orderedSame }) else {
            return
        }

        suggestionModels.append(.custom(title: normalizedSuggestion))
        suggestionsStore.saveSuggestions(suggestionModels)
        update(suggestions: Self.makeDisplayTitles(from: suggestionModels))
    }

    private func update(
        suggestions: [String]? = nil,
        isLoading: Bool? = nil,
        errorMessage: String? = nil
    ) {
        state = State(
            username: state.username,
            suggestions: suggestions ?? state.suggestions,
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

    private static func makeDisplayTitles(from suggestions: [SearchSuggestion]) -> [String] {
        suggestions.compactMap(makeDisplayTitle)
    }

    private static func makeDisplayTitle(from suggestion: SearchSuggestion) -> String? {
        switch suggestion.kind {
        case .builtIn:
            guard let builtInSuggestion = BuiltInSearchSuggestion(rawValue: suggestion.id) else {
                return suggestion.title
            }
            return makeDisplayTitle(from: builtInSuggestion)
        case .custom:
            return suggestion.title
        }
    }

    private static func makeDisplayTitle(from suggestion: BuiltInSearchSuggestion) -> String {
        switch suggestion {
        case .cozyEvening:
            return L10n.Search.Suggestion.cozyEvening
        case .darkMystery:
            return L10n.Search.Suggestion.darkMystery
        case .beautifulScifi:
            return L10n.Search.Suggestion.beautifulScifi
        case .slowSunday:
            return L10n.Search.Suggestion.slowSunday
        }
    }
}
