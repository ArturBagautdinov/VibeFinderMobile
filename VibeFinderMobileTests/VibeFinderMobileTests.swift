import Foundation
import Testing
@testable import VibeFinderMobile

@Suite(.serialized)
struct VibeFinderMobileTests {
    @Test
    func registerViewModelShowsPasswordMismatchBeforeNetworkRequest() {
        let repository = AuthRepositorySpy()
        let viewModel = RegisterViewModel(authRepository: repository)
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
        let viewModel = RegisterViewModel(authRepository: repository)
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
        let viewModel = LoginViewModel(authRepository: repository)
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
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )
        var states: [SearchViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.addCustomSuggestion("  Cyberpunk noir  ")

        #expect(suggestionsStore.savedSuggestions.contains { $0.title == "Cyberpunk noir" })
        #expect(states.last?.allSuggestions.contains { $0.title == "Cyberpunk noir" } == true)
        #expect(states.last?.visibleSuggestions.contains { $0.title == "Cyberpunk noir" } == true)
    }

    @Test
    @MainActor
    func searchViewModelDeletesCustomSuggestion() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        suggestionsStore.suggestions = [
            .custom(title: "Cyberpunk noir"),
            .custom(title: "Quiet mystery")
        ] + SearchSuggestion.defaults
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )
        let suggestion = viewModel.state.allSuggestions.first { $0.title == "Cyberpunk noir" }

        viewModel.deleteSuggestion(id: suggestion?.id ?? "")

        #expect(suggestionsStore.savedSuggestions.contains { $0.title == "Cyberpunk noir" } == false)
        #expect(viewModel.state.allSuggestions.contains { $0.title == "Cyberpunk noir" } == false)
        #expect(viewModel.state.allSuggestions.contains { $0.title == "Quiet mystery" } == true)
    }

    @Test
    @MainActor
    func searchViewModelDeletesBuiltInSuggestion() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )
        let builtInSuggestion = viewModel.state.allSuggestions.first

        viewModel.deleteSuggestion(id: builtInSuggestion?.id ?? "")

        #expect(suggestionsStore.savedSuggestions.contains { $0.id == builtInSuggestion?.id } == false)
        #expect(viewModel.state.allSuggestions.count == SearchSuggestion.defaults.count - 1)
    }

    @Test
    @MainActor
    func searchViewModelRestoresDefaultSuggestionsWithoutRemovingCustomOnes() {
        let repository = SearchRepositorySpy()
        let suggestionsStore = SearchSuggestionsStoreSpy()
        suggestionsStore.suggestions = [.custom(title: "Cyberpunk noir")]
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
        )

        viewModel.restoreDefaultSuggestions()

        #expect(suggestionsStore.savedSuggestions.contains { $0.title == "Cyberpunk noir" })
        #expect(SearchSuggestion.defaults.allSatisfy { defaultSuggestion in
            suggestionsStore.savedSuggestions.contains { $0.id == defaultSuggestion.id }
        })
        #expect(viewModel.state.allSuggestions.count == SearchSuggestion.defaults.count + 1)
        #expect(viewModel.state.allSuggestions.contains { $0.title == "Cyberpunk noir" })
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
        repository.pageByIDResult = .success(.fixture(id: 303))
        let viewModel = SearchViewModel(
            username: "Artur",
            searchRepository: repository,
            suggestionsStore: suggestionsStore
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
        let viewModel = SearchHistoryViewModel(searchRepository: repository)
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
        let viewModel = SearchHistoryViewModel(searchRepository: repository)
        var resultPage: SearchPage?
        viewModel.onResultsReady = { page in
            resultPage = page
        }

        viewModel.selectHistory(id: 202)
        await Task.yield()
        await Task.yield()

        #expect(repository.loadedPageIDs == [202])
        #expect(resultPage?.id == 202)
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
        let viewModel = SearchHistoryViewModel(searchRepository: repository)

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
        let viewModel = SearchHistoryViewModel(searchRepository: repository)

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
        let viewModel = SearchHistoryViewModel(searchRepository: repository)

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
