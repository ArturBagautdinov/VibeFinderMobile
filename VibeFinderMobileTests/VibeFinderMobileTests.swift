import Foundation
import Testing
@testable import VibeFinderMobile

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
    func searchViewModelShowsEmptyQueryBeforeNetworkRequest() {
        let repository = SearchRepositorySpy()
        let viewModel = SearchViewModel(username: "Artur", searchRepository: repository)
        var states: [SearchViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.search(query: "   ")

        #expect(repository.searchCallCount == 0)
        #expect(states.last?.errorMessage == L10n.Search.Validation.emptyQuery)
    }

    @Test
    func searchViewModelStoresSearchResult() {
        let repository = SearchRepositorySpy()
        repository.result = .success(.fixture())
        let viewModel = SearchViewModel(username: "Artur", searchRepository: repository)
        var states: [SearchViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.search(query: "cozy movie")

        #expect(repository.searchCallCount == 1)
        #expect(repository.lastQuery == "cozy movie")
        #expect(states.last?.result?.id == 101)
        #expect(states.last?.isLoading == false)
        #expect(states.last?.errorMessage == nil)
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
