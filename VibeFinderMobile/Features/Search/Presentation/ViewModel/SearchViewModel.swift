import Foundation

@MainActor
final class SearchViewModel {
    struct State {
        let username: String
        let avatar: ProfileAvatar?
        let avatarInitials: String
        let visibleSuggestions: [SearchSuggestionDisplayModel]
        let allSuggestions: [SearchSuggestionDisplayModel]
        let canShowMoreSuggestions: Bool
        let recentHistory: [SearchHistoryEntryDisplayModel]
        let recentHistoryInsertionID: Int?
        let isLoading: Bool
        let errorMessage: String?
    }

    private let searchRepository: SearchRepositoryProtocol
    private let suggestionsStore: SearchSuggestionsStoreProtocol
    private let analyticsTracker: AnalyticsTrackerProtocol
    private var suggestionModels: [SearchSuggestion]
    private var optimisticRecentHistory: [SearchHistoryEntryDisplayModel] = []
    private var pendingRecentHistoryInsertionID: Int?
    private(set) var state: State

    var onStateChange: ((State) -> Void)?
    var onResultsReady: ((SearchPage) -> Void)?

    private enum Constants {
        static let visibleSuggestionLimit = 5
        static let visibleHistoryLimit = 3
    }

    init(
        username: String,
        searchRepository: SearchRepositoryProtocol,
        suggestionsStore: SearchSuggestionsStoreProtocol,
        analyticsTracker: AnalyticsTrackerProtocol
    ) {
        self.searchRepository = searchRepository
        self.suggestionsStore = suggestionsStore
        self.analyticsTracker = analyticsTracker
        let suggestionModels = suggestionsStore.loadSuggestions()
        let suggestionState = Self.makeSuggestionState(from: suggestionModels)
        self.suggestionModels = suggestionModels
        self.state = State(
            username: username,
            avatar: nil,
            avatarInitials: String(username.prefix(1)).uppercased(),
            visibleSuggestions: suggestionState.visibleSuggestions,
            allSuggestions: suggestionState.allSuggestions,
            canShowMoreSuggestions: suggestionState.canShowMoreSuggestions,
            recentHistory: [],
            recentHistoryInsertionID: nil,
            isLoading: false,
            errorMessage: nil
        )
    }

    func loadRecentHistory() {
        searchRepository.loadHistory { [weak self] result in
            Task {
                switch result {
                case let .success(history):
                    self?.updateWithLoadedHistory(history)
                case let .failure(error):
                    self?.update(errorMessage: error.userMessage)
                }
            }
        }
    }

    func updateProfileAppearance(avatar: ProfileAvatar?, initials: String) {
        state = State(
            username: state.username,
            avatar: avatar,
            avatarInitials: initials,
            visibleSuggestions: state.visibleSuggestions,
            allSuggestions: state.allSuggestions,
            canShowMoreSuggestions: state.canShowMoreSuggestions,
            recentHistory: state.recentHistory,
            recentHistoryInsertionID: state.recentHistoryInsertionID,
            isLoading: state.isLoading,
            errorMessage: state.errorMessage
        )
        onStateChange?(state)
    }

    func search(query: String) {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else {
            update(errorMessage: L10n.Search.Validation.emptyQuery)
            return
        }

        analyticsTracker.track(SearchAnalyticsEvent.requested())
        update(isLoading: true, errorMessage: nil)
        let tracker = analyticsTracker
        searchRepository.search(query: normalizedQuery) { [weak self, tracker] result in
            Task {
                switch result {
                case let .success(page):
                    tracker.track(SearchAnalyticsEvent.succeeded(page: page))
                    self?.prependOptimisticHistory(from: page)
                    self?.update(isLoading: false, errorMessage: nil)
                    self?.loadRecentHistory()
                    self?.onResultsReady?(page)
                case let .failure(error):
                    tracker.track(SearchAnalyticsEvent.failed(error: error))
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

    func markRecentHistoryInsertionAnimationHandled() {
        pendingRecentHistoryInsertionID = nil
        state = State(
            username: state.username,
            avatar: state.avatar,
            avatarInitials: state.avatarInitials,
            visibleSuggestions: state.visibleSuggestions,
            allSuggestions: state.allSuggestions,
            canShowMoreSuggestions: state.canShowMoreSuggestions,
            recentHistory: state.recentHistory,
            recentHistoryInsertionID: nil,
            isLoading: state.isLoading,
            errorMessage: state.errorMessage
        )
    }

    func openHistoryResult(_ history: SearchHistoryEntryDisplayModel) {
        update(isLoading: true, errorMessage: nil)
        searchRepository.loadSearchPage(id: history.id) { [weak self] result in
            Task {
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
        suggestionModels: [SearchSuggestion]? = nil,
        recentHistory: [SearchHistoryEntryDisplayModel]? = nil,
        recentHistoryInsertionID: Int? = nil,
        isLoading: Bool? = nil,
        errorMessage: String? = nil
    ) {
        let suggestionState = suggestionModels.map(Self.makeSuggestionState)
        state = State(
            username: state.username,
            avatar: state.avatar,
            avatarInitials: state.avatarInitials,
            visibleSuggestions: suggestionState?.visibleSuggestions ?? state.visibleSuggestions,
            allSuggestions: suggestionState?.allSuggestions ?? state.allSuggestions,
            canShowMoreSuggestions: suggestionState?.canShowMoreSuggestions ?? state.canShowMoreSuggestions,
            recentHistory: recentHistory ?? state.recentHistory,
            recentHistoryInsertionID: recentHistoryInsertionID ?? state.recentHistoryInsertionID,
            isLoading: isLoading ?? state.isLoading,
            errorMessage: errorMessage
        )
        onStateChange?(state)
    }

    private func prependOptimisticHistory(from page: SearchPage) {
        let history = SearchHistoryDisplayModelMapper.makeDisplayModel(from: page)
        pendingRecentHistoryInsertionID = history.id
        optimisticRecentHistory.removeAll { $0.id == history.id }
        optimisticRecentHistory.insert(history, at: 0)
        optimisticRecentHistory = Array(optimisticRecentHistory.prefix(Constants.visibleHistoryLimit))
        update(
            recentHistory: mergeRecentHistory([]),
            recentHistoryInsertionID: history.id,
            errorMessage: nil
        )
    }

    private func updateWithLoadedHistory(_ history: [SearchHistoryEntry]) {
        let recentHistory = SearchHistoryDisplayModelMapper.makeDisplayModels(
            from: Array(history.prefix(Constants.visibleHistoryLimit))
        )
        update(
            recentHistory: mergeRecentHistory(recentHistory),
            recentHistoryInsertionID: pendingRecentHistoryInsertionID,
            errorMessage: nil
        )
    }

    private func mergeRecentHistory(
        _ loadedHistory: [SearchHistoryEntryDisplayModel]
    ) -> [SearchHistoryEntryDisplayModel] {
        var seenIDs = Set<Int>()
        let mergedHistory = (optimisticRecentHistory + loadedHistory).filter { history in
            seenIDs.insert(history.id).inserted
        }
        return Array(mergedHistory.prefix(Constants.visibleHistoryLimit))
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
        case .shortIndieGame:
            return L10n.Search.Suggestion.shortIndieGame
        case .darkFantasyBook:
            return L10n.Search.Suggestion.darkFantasyBook
        case .feelGoodSitcom:
            return L10n.Search.Suggestion.feelGoodSitcom
        case .postApocalypticDrama:
            return L10n.Search.Suggestion.postApocalypticDrama
        case .spaceOperaNight:
            return L10n.Search.Suggestion.spaceOperaNight
        case .couchCoopGame:
            return L10n.Search.Suggestion.couchCoopGame
        case .mysticalForestStory:
            return L10n.Search.Suggestion.mysticalForestStory
        case .smartHeistMovie:
            return L10n.Search.Suggestion.smartHeistMovie
        case .melancholicAnimation:
            return L10n.Search.Suggestion.melancholicAnimation
        case .historicalMystery:
            return L10n.Search.Suggestion.historicalMystery
        case .cosmicHorror:
            return L10n.Search.Suggestion.cosmicHorror
        case .warmRomance:
            return L10n.Search.Suggestion.warmRomance
        }
    }
}
