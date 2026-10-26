import Foundation
import Testing
@testable import VibeFinderMobile

@Suite(.serialized)
@MainActor
struct FavoritesViewModelTests {
    @Test
    func loadPublishesItemsAndTracksAggregateCount() async {
        let repository = FavoritesListRepositorySpy()
        let analytics = FavoritesListAnalyticsSpy()
        let viewModel = FavoritesViewModel(repository: repository, analyticsTracker: analytics)

        viewModel.loadFavorites()
        #expect(viewModel.state.isLoading)
        if case .notLoaded = viewModel.state.content {} else {
            Issue.record("Expected not-loaded content during initial request")
        }

        await complete(viewModel) {
            repository.complete(at: 0, with: .success([makeItem(5), makeItem(8)]))
        }

        guard case let .items(items) = viewModel.state.content else {
            Issue.record("Expected loaded favorites")
            return
        }
        #expect(items.map(\.mediaId) == [5, 8])
        #expect(!viewModel.state.isLoading)
        #expect(viewModel.state.errorMessage == nil)
        #expect(analytics.events.map(\.name) == ["favorites_list_requested", "favorites_list_succeeded"])
        #expect(analytics.events.last?.parameters["result_count"] == .integer(2))
        #expect(analytics.events.allSatisfy { $0.parameters["media_id"] == nil })
    }

    @Test
    func emptyResponsePublishesEmptyContent() async {
        let repository = FavoritesListRepositorySpy()
        let viewModel = FavoritesViewModel(repository: repository, analyticsTracker: FavoritesListAnalyticsSpy())

        viewModel.loadFavorites()
        await complete(viewModel) { repository.complete(at: 0, with: .success([])) }

        if case .empty = viewModel.state.content {} else {
            Issue.record("Expected empty state")
        }
        #expect(!viewModel.state.isLoading)
        #expect(viewModel.state.errorMessage == nil)
    }

    @Test
    func refreshKeepsItemsWhileLoadingAndAfterFailure() async {
        let repository = FavoritesListRepositorySpy()
        let analytics = FavoritesListAnalyticsSpy()
        let viewModel = FavoritesViewModel(repository: repository, analyticsTracker: analytics)

        viewModel.loadFavorites()
        await complete(viewModel) { repository.complete(at: 0, with: .success([makeItem(5)])) }

        viewModel.loadFavorites()
        guard case let .items(whileLoading) = viewModel.state.content else {
            Issue.record("Expected previous items during refresh")
            return
        }
        #expect(whileLoading.map(\.mediaId) == [5])
        #expect(viewModel.state.isLoading)

        await complete(viewModel) { repository.complete(at: 1, with: .failure(.statusCode(503))) }
        guard case let .items(afterFailure) = viewModel.state.content else {
            Issue.record("Expected previous items after refresh failure")
            return
        }
        #expect(afterFailure.map(\.mediaId) == [5])
        #expect(!viewModel.state.isLoading)
        #expect(viewModel.state.errorMessage == L10n.Error.httpStatus(503))
        #expect(analytics.events.last?.name == "favorites_list_failed")
        #expect(analytics.events.last?.parameters["error_category"] == .string("http_status"))

        viewModel.loadFavorites()
        #expect(viewModel.state.errorMessage == nil)
        await complete(viewModel) { repository.complete(at: 2, with: .success([makeItem(8)])) }
        guard case let .items(afterRetry) = viewModel.state.content else {
            Issue.record("Expected refreshed items")
            return
        }
        #expect(afterRetry.map(\.mediaId) == [8])
    }

    @Test
    func newerRequestWinsOverOlderResponse() async {
        let repository = FavoritesListRepositorySpy()
        let analytics = FavoritesListAnalyticsSpy()
        let viewModel = FavoritesViewModel(repository: repository, analyticsTracker: analytics)

        viewModel.loadFavorites()
        viewModel.loadFavorites()
        #expect(repository.requestCount == 2)

        await complete(viewModel) {
            repository.complete(at: 0, with: .success([makeItem(5)]))
            repository.complete(at: 1, with: .success([makeItem(8)]))
        }

        guard case let .items(items) = viewModel.state.content else {
            Issue.record("Expected latest response")
            return
        }
        #expect(items.map(\.mediaId) == [8])
        #expect(analytics.events.map(\.name) == [
            "favorites_list_requested",
            "favorites_list_requested",
            "favorites_list_succeeded"
        ])
    }

    private func complete(_ viewModel: FavoritesViewModel, action: () -> Void) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                guard !state.isLoading else { return }
                continuation.resume()
            }
            action()
        }
        viewModel.onStateChange = nil
    }

    private func makeItem(_ mediaId: Int) -> FavoriteItem {
        FavoriteItem(
            mediaId: mediaId,
            title: "Arrival",
            mediaType: .movie,
            releaseYear: 2016,
            imageUrl: nil,
            shortDescription: nil
        )
    }
}

private final class FavoritesListRepositorySpy: FavoriteRepositoryProtocol {
    private var completions: [(Result<[FavoriteItem], APIError>) -> Void] = []
    var requestCount: Int { completions.count }

    func loadFavorites(completion: @escaping (Result<[FavoriteItem], APIError>) -> Void) {
        completions.append(completion)
    }

    func setFavorite(mediaId: Int, isFavorite: Bool, completion: @escaping (Result<Bool, APIError>) -> Void) {
        Issue.record("Favorites list should not mutate favorites")
        completion(.failure(.unknown))
    }

    func complete(at index: Int, with result: Result<[FavoriteItem], APIError>) {
        completions[index](result)
    }
}

private final class FavoritesListAnalyticsSpy: AnalyticsTrackerProtocol {
    private(set) var events: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        events.append(event)
    }
}
