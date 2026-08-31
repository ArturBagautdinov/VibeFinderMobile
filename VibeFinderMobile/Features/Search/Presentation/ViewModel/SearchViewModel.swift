import Foundation

@MainActor
final class SearchViewModel {
    struct State {
        let username: String
        let visibleSuggestions: [SearchSuggestionDisplayModel]
        let allSuggestions: [SearchSuggestionDisplayModel]
        let canShowMoreSuggestions: Bool
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

    private enum Constants {
        static let visibleSuggestionLimit = 5
    }

    init(
        username: String,
        searchRepository: SearchRepositoryProtocol,
        suggestionsStore: SearchSuggestionsStoreProtocol
    ) {
        self.searchRepository = searchRepository
        self.suggestionsStore = suggestionsStore
        let suggestionModels = suggestionsStore.loadSuggestions()
        let suggestionState = Self.makeSuggestionState(from: suggestionModels)
        self.suggestionModels = suggestionModels
        self.state = State(
            username: username,
            visibleSuggestions: suggestionState.visibleSuggestions,
            allSuggestions: suggestionState.allSuggestions,
            canShowMoreSuggestions: suggestionState.canShowMoreSuggestions,
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
            Task { @MainActor in
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

        guard !state.allSuggestions.contains(where: { displayModel in
            displayModel.title.caseInsensitiveCompare(normalizedSuggestion) == .orderedSame
        }) else {
            return
        }

        suggestionModels.insert(.custom(title: normalizedSuggestion), at: 0)
        suggestionsStore.saveSuggestions(suggestionModels)
        update(suggestionModels: suggestionModels)
    }

    func deleteSuggestion(id: String) {
        guard suggestionModels.contains(where: { $0.id == id }) else {
            return
        }

        suggestionModels.removeAll { $0.id == id }
        suggestionsStore.saveSuggestions(suggestionModels)
        update(suggestionModels: suggestionModels)
    }

    func restoreDefaultSuggestions() {
        suggestionModels = suggestionsStore.restoreDefaultSuggestions()
        update(suggestionModels: suggestionModels)
    }

    private func update(
        suggestionModels: [SearchSuggestion]? = nil,
        isLoading: Bool? = nil,
        errorMessage: String? = nil
    ) {
        let suggestionState = suggestionModels.map(Self.makeSuggestionState)
        state = State(
            username: state.username,
            visibleSuggestions: suggestionState?.visibleSuggestions ?? state.visibleSuggestions,
            allSuggestions: suggestionState?.allSuggestions ?? state.allSuggestions,
            canShowMoreSuggestions: suggestionState?.canShowMoreSuggestions ?? state.canShowMoreSuggestions,
            recentVibes: state.recentVibes,
            isLoading: isLoading ?? state.isLoading,
            errorMessage: errorMessage
        )
        onStateChange?(state)
    }

    private static func makeSuggestionState(
        from suggestions: [SearchSuggestion]
    ) -> (
        visibleSuggestions: [SearchSuggestionDisplayModel],
        allSuggestions: [SearchSuggestionDisplayModel],
        canShowMoreSuggestions: Bool
    ) {
        let allSuggestions = suggestions.compactMap(makeDisplayModel)
        let currentBuiltInIDs = Set(
            suggestions
                .filter { $0.kind == .builtIn }
                .map(\.id)
        )
        let defaultBuiltInIDs = Set(SearchSuggestion.defaults.map(\.id))
        let hasMissingDefaultSuggestions = !defaultBuiltInIDs.isSubset(of: currentBuiltInIDs)
        return (
            visibleSuggestions: Array(allSuggestions.prefix(Constants.visibleSuggestionLimit)),
            allSuggestions: allSuggestions,
            canShowMoreSuggestions: allSuggestions.isEmpty
                || allSuggestions.count > Constants.visibleSuggestionLimit
                || hasMissingDefaultSuggestions
        )
    }

    private static func makeDisplayModel(from suggestion: SearchSuggestion) -> SearchSuggestionDisplayModel? {
        switch suggestion.kind {
        case .builtIn:
            guard let builtInSuggestion = BuiltInSearchSuggestion(rawValue: suggestion.id) else {
                return suggestion.title.map {
                    SearchSuggestionDisplayModel(id: suggestion.id, title: $0, isDeletable: true)
                }
            }
            return SearchSuggestionDisplayModel(
                id: suggestion.id,
                title: makeDisplayTitle(from: builtInSuggestion),
                isDeletable: true
            )
        case .custom:
            return suggestion.title.map {
                SearchSuggestionDisplayModel(id: suggestion.id, title: $0, isDeletable: true)
            }
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
        case .rainyNightMovie:
            return L10n.Search.Suggestion.rainyNightMovie
        case .cozyGame:
            return L10n.Search.Suggestion.cozyGame
        case .emotionalScifi:
            return L10n.Search.Suggestion.emotionalScifi
        case .somethingWeird:
            return L10n.Search.Suggestion.somethingWeird
        case .lateNightThriller:
            return L10n.Search.Suggestion.lateNightThriller
        case .weekendAdventure:
            return L10n.Search.Suggestion.weekendAdventure
        case .comfortBook:
            return L10n.Search.Suggestion.comfortBook
        case .mindBendingStory:
            return L10n.Search.Suggestion.mindBendingStory
        }
    }
}
