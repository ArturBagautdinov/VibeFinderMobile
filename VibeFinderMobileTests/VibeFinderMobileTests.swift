import Foundation
import Testing
@testable import VibeFinderMobile

@Suite(.serialized)
struct VibeFinderMobileTests {
    @Test
    func registerViewModelShowsPasswordMismatchBeforeNetworkRequest() {
        let repository = AuthRepositorySpy()
        let viewModel = RegisterViewModel(authRepository: repository, analyticsTracker: SearchAnalyticsSpy())
        var states: [RegisterViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.register(
            email: "artur@example.com",
            username: "artur",
            firstName: "Artur",
            lastName: "Bagautdinov",
            password: "password123",
            confirmPassword: "password321"
        )

        #expect(repository.registerCallCount == 0)
        #expect(states.last?.errorMessage == L10n.Auth.Validation.passwordMismatch)
    }

    @Test
    func registerViewModelShowsRequiredFieldsBeforeNetworkRequest() {
        let repository = AuthRepositorySpy()
        let viewModel = RegisterViewModel(authRepository: repository, analyticsTracker: SearchAnalyticsSpy())
        var states: [RegisterViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.register(
            email: "",
            username: "",
            firstName: "",
            lastName: "",
            password: "",
            confirmPassword: ""
        )

        #expect(repository.registerCallCount == 0)
        #expect(states.last?.errorMessage == L10n.Auth.Validation.requiredFields)
    }

    @Test
    func loginViewModelShowsRequiredFieldsBeforeNetworkRequest() {
        let repository = AuthRepositorySpy()
        let viewModel = LoginViewModel(authRepository: repository, analyticsTracker: SearchAnalyticsSpy())
        var states: [LoginViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.login(login: "", password: "")

        #expect(repository.loginCallCount == 0)
        #expect(states.last?.errorMessage == L10n.Auth.Validation.requiredFields)
    }

    @Test
    @MainActor
    func searchViewModelShowsEmptyQueryBeforeNetworkRequest() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )
        var states: [SearchViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.search(query: "   ")

        #expect(repository.searchCallCount == 0)
        #expect(states.last?.errorMessage == L10n.Search.Validation.emptyQuery)
    }

    @Test
    @MainActor
    func searchViewModelUpdatesAvatarAndKeepsItAfterHistoryRefresh() async {
        let repository = SearchRepositorySpy()
        let viewModel = SearchViewModel(
            username: "artur",
            searchRepository: repository,
            suggestionsStore: SearchSuggestionsStoreSpy()
        )
        let avatar = ProfileAvatar(
            style: .symbol,
            symbol: "gamecontroller.fill",
            backgroundHex: "#4F46E5",
            foregroundHex: "#FFFFFF"
        )
        var observedAvatar: ProfileAvatar?
        viewModel.onStateChange = { observedAvatar = $0.avatar }

        viewModel.updateProfileAppearance(avatar: avatar, initials: "AB")
        #expect(observedAvatar == avatar)
        #expect(viewModel.state.avatarInitials == "AB")

        viewModel.loadRecentHistory()
        await Task.yield()
        await Task.yield()
        #expect(viewModel.state.avatar == avatar)
        #expect(viewModel.state.avatarInitials == "AB")

        viewModel.updateProfileAppearance(avatar: nil, initials: "AB")
        #expect(viewModel.state.avatar == nil)
    }

    @Test
    @MainActor
    func searchViewModelEmitsSearchResult() async {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        repository.result = .success(.fixture())
        repository.historyResult = .success([.fixture(id: 101, originalQuery: "cozy movie", resultCount: 1)])
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )
        var states: [SearchViewModel.State] = []
        var resultPage: SearchPage?
        viewModel.onStateChange = { states.append($0) }
        viewModel.onResultsReady = { page in
            resultPage = page
        }

        viewModel.search(query: "cozy movie")
        await Task.yield()
        await Task.yield()

        #expect(repository.searchCallCount == 1)
        #expect(repository.lastQuery == "cozy movie")
        #expect(resultPage?.id == 101)
        #expect(states.last?.isLoading == false)
        #expect(states.last?.errorMessage == nil)
    }

    @Test
    @MainActor
    func searchTracksRequestAndSuccessWithoutQueryText() async {
        let repository = SearchRepositorySpy()
        repository.result = .success(.fixture())
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: SearchSuggestionsStoreSpy(),
            analyticsTracker: analytics
        )

        viewModel.search(query: " private search text ")
        await Task.yield()
        await Task.yield()

        #expect(repository.lastQuery == "private search text")
        #expect(analytics.events == [
            AnalyticsEvent(name: "search_requested"),
            AnalyticsEvent(
                name: "search_succeeded",
                parameters: ["result_count": .integer(1)]
            )
        ])
    }

    @Test
    @MainActor
    func searchTracksFailureCategoryButNotErrorMessage() async {
        let repository = SearchRepositorySpy()
        repository.result = .failure(.unknown)
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: SearchSuggestionsStoreSpy(),
            analyticsTracker: analytics
        )

        viewModel.search(query: "private search text")
        await Task.yield()
        await Task.yield()

        #expect(analytics.events == [
            AnalyticsEvent(name: "search_requested"),
            AnalyticsEvent(
                name: "search_failed",
                parameters: ["error_category": .string("unknown")]
            )
        ])
    }

    @Test
    @MainActor
    func emptySearchDoesNotTrackNetworkRequest() {
        let repository = SearchRepositorySpy()
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: SearchSuggestionsStoreSpy(),
            analyticsTracker: analytics
        )

        viewModel.search(query: "  ")

        #expect(repository.searchCallCount == 0)
        #expect(analytics.events.isEmpty)
    }

    @Test
    @MainActor
    func searchViewModelKeepsSuccessfulSearchInRecentHistoryWhenAPIHistoryIsEmpty() async {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        repository.result = .success(.fixture(id: 404))
        repository.historyResult = .success([])
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )

        viewModel.search(query: "cozy movie")
        await Task.yield()
        await Task.yield()

        #expect(viewModel.state.recentHistory.first?.id == 404)
        #expect(viewModel.state.recentHistory.first?.query == "cozy movie")
    }

    @Test
    @MainActor
    func searchViewModelStoresCustomSuggestion() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore,
            analyticsTracker: analytics
        )
        var states: [SearchViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.addCustomSuggestion("  Cyberpunk noir  ")
        viewModel.addCustomSuggestion("Cyberpunk noir")

        #expect(suggestionsStore.savedSuggestions.contains { $0.title == "Cyberpunk noir" })
        #expect(states.last?.allSuggestions.contains { $0.title == "Cyberpunk noir" } == true)
        #expect(states.last?.visibleSuggestions.contains { $0.title == "Cyberpunk noir" } == true)
        #expect(analytics.events == [
            AnalyticsEvent(
                name: "search_suggestion_added",
                parameters: ["kind": .string("custom")]
            )
        ])
    }

    @Test
    @MainActor
    func searchViewModelTracksSuggestionSelectionByKind() {
        let suggestionsStore = SearchSuggestionsStoreSpy()
        suggestionsStore.suggestions.insert(.custom(title: "Private suggestion"), at: 0)
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: SearchRepositorySpy(),
            suggestionsStore: suggestionsStore,
            analyticsTracker: analytics
        )
        let customID = suggestionsStore.suggestions[0].id
        let builtInID = SearchSuggestion.defaults[0].id

        viewModel.suggestionSelected(id: customID)
        viewModel.suggestionSelected(id: builtInID)
        viewModel.suggestionSelected(id: "missing")

        #expect(analytics.events == [
            AnalyticsEvent(
                name: "search_suggestion_selected",
                parameters: ["kind": .string("custom")]
            ),
            AnalyticsEvent(
                name: "search_suggestion_selected",
                parameters: ["kind": .string("built_in")]
            )
        ])
    }

    @Test
    @MainActor
    func searchViewModelDeletesCustomSuggestion() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        let analytics = SearchAnalyticsSpy()
        suggestionsStore.suggestions = [
            .custom(title: "Cyberpunk noir"),
            .custom(title: "Quiet mystery")
        ] + SearchSuggestion.defaults
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore,
            analyticsTracker: analytics
        )
        let suggestion = viewModel.state.allSuggestions.first { $0.title == "Cyberpunk noir" }

        viewModel.deleteSuggestion(id: suggestion?.id ?? "")

        #expect(suggestionsStore.savedSuggestions.contains { $0.title == "Cyberpunk noir" } == false)
        #expect(viewModel.state.allSuggestions.contains { $0.title == "Cyberpunk noir" } == false)
        #expect(viewModel.state.allSuggestions.contains { $0.title == "Quiet mystery" } == true)
        #expect(analytics.events == [
            AnalyticsEvent(
                name: "search_suggestion_deleted",
                parameters: ["kind": .string("custom")]
            )
        ])
    }

    @Test
    @MainActor
    func searchViewModelDeletesBuiltInSuggestion() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore,
            analyticsTracker: analytics
        )
        let builtInSuggestion = viewModel.state.allSuggestions.first

        viewModel.deleteSuggestion(id: builtInSuggestion?.id ?? "")

        #expect(suggestionsStore.savedSuggestions.contains { $0.id == builtInSuggestion?.id } == false)
        #expect(viewModel.state.allSuggestions.count == SearchSuggestion.defaults.count - 1)
        #expect(analytics.events == [
            AnalyticsEvent(
                name: "search_suggestion_deleted",
                parameters: ["kind": .string("built_in")]
            )
        ])
    }

    @Test
    @MainActor
    func searchViewModelRestoresDefaultSuggestionsWithoutRemovingCustomOnes() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        let analytics = SearchAnalyticsSpy()
        suggestionsStore.suggestions = [.custom(title: "Cyberpunk noir")]
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore,
            analyticsTracker: analytics
        )

        viewModel.restoreDefaultSuggestions()

        #expect(suggestionsStore.savedSuggestions.contains { $0.title == "Cyberpunk noir" })
        #expect(SearchSuggestion.defaults.allSatisfy { defaultSuggestion in
            suggestionsStore.savedSuggestions.contains { $0.id == defaultSuggestion.id }
        })
        #expect(viewModel.state.allSuggestions.count == SearchSuggestion.defaults.count + 1)
        #expect(viewModel.state.allSuggestions.contains { $0.title == "Cyberpunk noir" })
        #expect(analytics.events == [
            AnalyticsEvent(name: "search_suggestions_defaults_restored")
        ])
    }

    @Test
    @MainActor
    func searchViewModelKeepsSuggestionsPickerAvailableWhenEmpty() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        suggestionsStore.suggestions = []
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )

        #expect(viewModel.state.visibleSuggestions.isEmpty)
        #expect(viewModel.state.allSuggestions.isEmpty)
        #expect(viewModel.state.canShowMoreSuggestions == true)
    }

    @Test
    @MainActor
    func searchViewModelKeepsSuggestionsPickerAvailableWhenDefaultsAreMissing() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        suggestionsStore.suggestions = [.custom(title: "Cyberpunk noir")]
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )

        #expect(viewModel.state.visibleSuggestions.count == 1)
        #expect(viewModel.state.allSuggestions.count == 1)
        #expect(viewModel.state.canShowMoreSuggestions == true)
    }

    @Test
    @MainActor
    func searchViewModelLimitsVisibleSuggestions() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )

        #expect(viewModel.state.visibleSuggestions.count == 5)
        #expect(viewModel.state.allSuggestions.count == SearchSuggestion.defaults.count)
        #expect(viewModel.state.canShowMoreSuggestions == true)
    }

    @Test
    @MainActor
    func searchViewModelLoadsRecentHistory() async {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        repository.historyResult = .success([
            .fixture(id: 101, originalQuery: "Rainy movie", resultCount: 3),
            .fixture(id: 102, originalQuery: "Cozy game", resultCount: 2)
        ])
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )

        viewModel.loadRecentHistory()
        await Task.yield()
        await Task.yield()

        #expect(viewModel.state.recentHistory.map(\.query) == ["Rainy movie", "Cozy game"])
    }

    @Test
    @MainActor
    func searchViewModelLoadsResultByHistoryID() async {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        let analytics = SearchAnalyticsSpy()
        repository.pageByIDResult = .success(.fixture(id: 303))
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore,
            analyticsTracker: analytics
        )
        var resultPage: SearchPage?
        viewModel.onResultsReady = { page in
            resultPage = page
        }

        viewModel.openHistoryResult(.fixture(id: 303, originalQuery: "Rainy movie"))
        await Task.yield()
        await Task.yield()

        #expect(repository.searchCallCount == 0)
        #expect(repository.loadedPageIDs == [303])
        #expect(resultPage?.id == 303)
        #expect(analytics.events == [
            AnalyticsEvent(
                name: "search_history_open_requested",
                parameters: ["source": .string("recent")]
            ),
            AnalyticsEvent(
                name: "search_history_open_succeeded",
                parameters: ["source": .string("recent")]
            )
        ])
    }

    @Test
    @MainActor
    func recentHistoryOpenTracksFailureWithoutQueryOrID() async {
        let repository = SearchRepositorySpy()
        repository.pageByIDResult = .failure(.unknown)
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: SearchSuggestionsStoreSpy(),
            analyticsTracker: analytics
        )

        viewModel.openHistoryResult(.fixture(id: 303, originalQuery: "private query"))
        await Task.yield()
        await Task.yield()

        #expect(analytics.events == [
            AnalyticsEvent(
                name: "search_history_open_requested",
                parameters: ["source": .string("recent")]
            ),
            AnalyticsEvent(
                name: "search_history_open_failed",
                parameters: [
                    "source": .string("recent"),
                    "error_category": .string("unknown")
                ]
            )
        ])
    }

    @Test
    @MainActor
    func searchHistoryViewModelLoadsFullHistory() async {
        let repository = SearchRepositorySpy()
        repository.historyResult = .success([
            .fixture(id: 101, originalQuery: "Rainy movie", resultCount: 3),
            .fixture(id: 102, originalQuery: "Cozy game", resultCount: 2),
            .fixture(id: 103, originalQuery: "Dark book", resultCount: 4)
        ])
        let viewModel = SearchHistoryViewModel(
            searchRepository: repository,
            analyticsTracker: SearchAnalyticsSpy()
        )
        var states: [SearchHistoryViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.loadHistory()
        await Task.yield()
        await Task.yield()

        #expect(states.last?.history.map(\.query) == ["Rainy movie", "Cozy game", "Dark book"])
        #expect(states.last?.isEmpty == false)
    }

    @Test
    @MainActor
    func searchHistoryViewModelLoadsResultByHistoryID() async {
        let repository = SearchRepositorySpy()
        repository.pageByIDResult = .success(.fixture(id: 202))
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchHistoryViewModel(
            searchRepository: repository,
            analyticsTracker: analytics
        )
        var resultPage: SearchPage?
        viewModel.onResultsReady = { page in
            resultPage = page
        }

        viewModel.selectHistory(id: 202)
        await Task.yield()
        await Task.yield()

        #expect(repository.loadedPageIDs == [202])
        #expect(resultPage?.id == 202)
        #expect(analytics.events == [
            AnalyticsEvent(
                name: "search_history_open_requested",
                parameters: ["source": .string("full")]
            ),
            AnalyticsEvent(
                name: "search_history_open_succeeded",
                parameters: ["source": .string("full")]
            )
        ])
    }

    @Test
    @MainActor
    func fullHistoryOpenTracksFailureWithoutID() async {
        let repository = SearchRepositorySpy()
        repository.pageByIDResult = .failure(.unknown)
        let analytics = SearchAnalyticsSpy()
        let viewModel = SearchHistoryViewModel(
            searchRepository: repository,
            analyticsTracker: analytics
        )

        viewModel.selectHistory(id: 202)
        await Task.yield()
        await Task.yield()

        #expect(analytics.events == [
            AnalyticsEvent(
                name: "search_history_open_requested",
                parameters: ["source": .string("full")]
            ),
            AnalyticsEvent(
                name: "search_history_open_failed",
                parameters: [
                    "source": .string("full"),
                    "error_category": .string("unknown")
                ]
            )
        ])
    }

    @Test
    @MainActor
    func searchHistoryViewModelDeletesHistoryItem() async {
        let repository = SearchRepositorySpy()
        repository.historyResult = .success([
            .fixture(id: 101, originalQuery: "Rainy movie", resultCount: 3),
            .fixture(id: 102, originalQuery: "Cozy game", resultCount: 2)
        ])
        repository.deleteHistoryItemResult = .success(())
        let viewModel = SearchHistoryViewModel(
            searchRepository: repository,
            analyticsTracker: SearchAnalyticsSpy()
        )

        viewModel.loadHistory()
        await Task.yield()
        await Task.yield()
        var states: [SearchHistoryViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }
        viewModel.deleteHistoryItem(id: 101)
        await Task.yield()
        await Task.yield()

        #expect(repository.deletedHistoryItemIDs == [101])
        #expect(states.first?.history.map(\.id) == [102])
        #expect(states.first?.isInitialLoading == false)
        #expect(states.first?.isMutating == true)
        #expect(viewModel.state.history.map(\.id) == [102])
        #expect(viewModel.state.isEmpty == false)
        #expect(viewModel.state.isMutating == false)
    }

    @Test
    @MainActor
    func searchHistoryViewModelRestoresHistoryItemWhenDeleteFails() async {
        let repository = SearchRepositorySpy()
        repository.historyResult = .success([
            .fixture(id: 101, originalQuery: "Rainy movie", resultCount: 3),
            .fixture(id: 102, originalQuery: "Cozy game", resultCount: 2)
        ])
        repository.deleteHistoryItemResult = .failure(.unknown)
        let viewModel = SearchHistoryViewModel(
            searchRepository: repository,
            analyticsTracker: SearchAnalyticsSpy()
        )

        viewModel.loadHistory()
        await Task.yield()
        await Task.yield()
        viewModel.deleteHistoryItem(id: 101)
        await Task.yield()
        await Task.yield()

        #expect(repository.deletedHistoryItemIDs == [101])
        #expect(viewModel.state.history.map(\.id) == [101, 102])
        #expect(viewModel.state.errorMessage == L10n.Error.unknown)
        #expect(viewModel.state.isMutating == false)
    }

    @Test
    @MainActor
    func searchHistoryViewModelClearsHistory() async {
        let repository = SearchRepositorySpy()
        repository.historyResult = .success([
            .fixture(id: 101, originalQuery: "Rainy movie", resultCount: 3)
        ])
        repository.clearHistoryResult = .success(())
        let viewModel = SearchHistoryViewModel(
            searchRepository: repository,
            analyticsTracker: SearchAnalyticsSpy()
        )

        viewModel.loadHistory()
        await Task.yield()
        await Task.yield()
        var states: [SearchHistoryViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }
        viewModel.clearHistory()
        await Task.yield()
        await Task.yield()

        #expect(repository.clearHistoryCallCount == 1)
        #expect(states.first?.history.isEmpty == true)
        #expect(states.first?.isInitialLoading == false)
        #expect(states.first?.isMutating == true)
        #expect(viewModel.state.history.isEmpty)
        #expect(viewModel.state.isEmpty)
        #expect(viewModel.state.isMutating == false)
    }

    @Test
    @MainActor
    func coreDataSearchSuggestionsStorePersistsCustomSuggestions() {
        let store = CoreDataSearchSuggestionsStore(
            coreDataStack: CoreDataStack(name: "VibeFinderMobileTests-\(UUID().uuidString)", inMemory: true)
        )
        var suggestions = store.loadSuggestions()
        suggestions.append(.custom(title: "Quiet cyberpunk"))

        store.saveSuggestions(suggestions)
        let savedSuggestions = store.loadSuggestions()

        #expect(savedSuggestions.contains { $0.title == "Quiet cyberpunk" })
        #expect(savedSuggestions.count == suggestions.count)
    }

    @Test
    @MainActor
    func coreDataSearchSuggestionsStoreKeepsEmptySuggestionsUntilRestore() {
        let store = CoreDataSearchSuggestionsStore(
            coreDataStack: CoreDataStack(name: "VibeFinderMobileTests-\(UUID().uuidString)", inMemory: true)
        )

        store.saveSuggestions([])
        #expect(store.loadSuggestions().isEmpty)

        let restoredSuggestions = store.restoreDefaultSuggestions()
        #expect(restoredSuggestions == SearchSuggestion.defaults)
        #expect(store.loadSuggestions() == SearchSuggestion.defaults)
    }

    @Test
    @MainActor
    func coreDataSearchSuggestionsStoreRestoresDefaultsWithoutRemovingCustomOnes() {
        let store = CoreDataSearchSuggestionsStore(
            coreDataStack: CoreDataStack(name: "VibeFinderMobileTests-\(UUID().uuidString)", inMemory: true)
        )
        let customSuggestion = SearchSuggestion.custom(title: "Cyberpunk noir")

        store.saveSuggestions([customSuggestion])
        let restoredSuggestions = store.restoreDefaultSuggestions()

        #expect(restoredSuggestions.contains(customSuggestion))
        #expect(SearchSuggestion.defaults.allSatisfy { defaultSuggestion in
            restoredSuggestions.contains { $0.id == defaultSuggestion.id }
        })
        #expect(store.loadSuggestions() == restoredSuggestions)
    }

    @Test
    @MainActor
    func searchResultsViewModelBuildsCellViewModels() {
        let viewModel = SearchResultsViewModel(page: .fixture())

        #expect(viewModel.sections.count == 1)
        #expect(viewModel.sections.first?.title == "Exact match")
        #expect(viewModel.sections.first?.items.first?.title == "Arrival")
        #expect(viewModel.sections.first?.items.first?.meta == "2016 · sci-fi")
        #expect(viewModel.sections.first?.items.first?.matchText == "★ 92%")
        #expect(viewModel.sections.first?.items.first?.isTopMatch == true)
    }
}

private final class AuthRepositorySpy: AuthRepositoryProtocol {
    private(set) var loginCallCount = 0
    private(set) var registerCallCount = 0

    func login(
        login: String,
        password: String,
        completion: @escaping (Result<AuthSession, APIError>) -> Void
    ) {
        loginCallCount += 1
    }

    func register(
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        password: String,
        confirmPassword: String,
        completion: @escaping (Result<FormSubmission, APIError>) -> Void
    ) {
        registerCallCount += 1
    }

    func refreshSession(completion: @escaping (Result<AuthSession, APIError>) -> Void) {}

    func logout(completion: @escaping (Result<Void, APIError>) -> Void) {}

    func resendEmailVerification(
        email: String,
        completion: @escaping (Result<FormSubmission, APIError>) -> Void
    ) {}

    func confirmEmailVerification(
        token: String,
        completion: @escaping (Result<EmailVerification, APIError>) -> Void
    ) {}
}

private final class SearchRepositorySpy: SearchRepositoryProtocol {
    private(set) var searchCallCount = 0
    private(set) var lastQuery: String?
    private(set) var loadedPageIDs: [Int] = []
    private(set) var deletedHistoryItemIDs: [Int] = []
    private(set) var clearHistoryCallCount = 0
    var result: Result<SearchPage, APIError> = .failure(.unknown)
    var historyResult: Result<[SearchHistoryEntry], APIError> = .success([])
    var pageByIDResult: Result<SearchPage, APIError> = .failure(.unknown)
    var deleteHistoryItemResult: Result<Void, APIError> = .success(())
    var clearHistoryResult: Result<Void, APIError> = .success(())

    func search(query: String, completion: @escaping (Result<SearchPage, APIError>) -> Void) {
        searchCallCount += 1
        lastQuery = query
        completion(result)
    }

    func loadHistory(completion: @escaping (Result<[SearchHistoryEntry], APIError>) -> Void) {
        completion(historyResult)
    }

    func loadSearchPage(id: Int, completion: @escaping (Result<SearchPage, APIError>) -> Void) {
        loadedPageIDs.append(id)
        completion(pageByIDResult)
    }

    func deleteHistoryItem(id: Int, completion: @escaping (Result<Void, APIError>) -> Void) {
        deletedHistoryItemIDs.append(id)
        completion(deleteHistoryItemResult)
    }

    func clearHistory(completion: @escaping (Result<Void, APIError>) -> Void) {
        clearHistoryCallCount += 1
        completion(clearHistoryResult)
    }
}

private final class SearchSuggestionsStoreSpy: SearchSuggestionsStoreProtocol {
    private(set) var savedSuggestions: [SearchSuggestion] = []
    var suggestions: [SearchSuggestion] = SearchSuggestion.defaults

    func loadSuggestions() -> [SearchSuggestion] {
        suggestions
    }

    func saveSuggestions(_ suggestions: [SearchSuggestion]) {
        savedSuggestions = suggestions
        self.suggestions = suggestions
    }

    func restoreDefaultSuggestions() -> [SearchSuggestion] {
        let currentIDs = Set(suggestions.map(\.id))
        let missingDefaultSuggestions = SearchSuggestion.defaults.filter {
            !currentIDs.contains($0.id)
        }
        let restoredSuggestions = suggestions + missingDefaultSuggestions
        saveSuggestions(restoredSuggestions)
        return restoredSuggestions
    }
}

private final class SearchAnalyticsSpy: AnalyticsTrackerProtocol {
    private(set) var events: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        events.append(event)
    }
}

private extension SearchViewModel {
    convenience init(
        username: String,
        searchRepository: SearchRepositoryProtocol,
        suggestionsStore: SearchSuggestionsStoreProtocol
    ) {
        self.init(
            username: username,
            searchRepository: searchRepository,
            suggestionsStore: suggestionsStore,
            analyticsTracker: SearchAnalyticsSpy()
        )
    }
}

private extension SearchPage {
    static func fixture(id: Int = 101) -> SearchPage {
        SearchPage(
            id: id,
            originalQuery: "cozy movie",
            refinedQuery: nil,
            summary: "A calm selection",
            quickRefinements: ["more sci-fi"],
            buckets: [
                SearchBucket(
                    code: "EXACT_MATCH",
                    title: "Exact match",
                    description: "Best fit",
                    items: [
                        SearchRecommendation(
                            mediaId: 5,
                            title: "Arrival",
                            mediaType: "MOVIE",
                            releaseYear: 2016,
                            imageUrl: nil,
                            genres: ["sci-fi"],
                            shortDescription: "Short text",
                            overallMatch: 92,
                            explanation: "Why it fits",
                            warning: nil,
                            rating: 8.1,
                            completionLabel: "Not marked yet"
                        )
                    ]
                )
            ]
        )
    }
}

private extension SearchHistoryEntry {
    static func fixture(
        id: Int = 101,
        originalQuery: String = "cozy movie",
        refinedQuery: String? = nil,
        resultCount: Int = 8,
        createdAtDisplay: String = "01.09.2026 12:00"
    ) -> SearchHistoryEntry {
        SearchHistoryEntry(
            id: id,
            originalQuery: originalQuery,
            refinedQuery: refinedQuery,
            resultCount: resultCount,
            createdAtDisplay: createdAtDisplay
        )
    }
}

private extension SearchHistoryEntryDisplayModel {
    static func fixture(
        id: Int = 101,
        originalQuery: String = "cozy movie",
        title: String? = nil
    ) -> SearchHistoryEntryDisplayModel {
        SearchHistoryEntryDisplayModel(
            id: id,
            title: title ?? originalQuery,
            query: originalQuery,
            subtitle: "8 recommendations · 01.09.2026 12:00"
        )
    }
}
