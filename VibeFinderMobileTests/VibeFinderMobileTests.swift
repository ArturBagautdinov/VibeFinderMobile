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

        #expect(repository.searchCallCount == 1)
        #expect(repository.lastQuery == "cozy movie")
        #expect(resultPage?.id == 101)
        #expect(states.last?.isLoading == false)
        #expect(states.last?.errorMessage == nil)
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
    var result: Result<SearchPage, APIError> = .failure(.unknown)

    func search(query: String, completion: @escaping (Result<SearchPage, APIError>) -> Void) {
        searchCallCount += 1
        lastQuery = query
        completion(result)
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
    static func fixture() -> SearchPage {
        SearchPage(
            id: 101,
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
