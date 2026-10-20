import Foundation
import Testing
import UIKit
@testable import VibeFinderMobile

@Suite(.serialized)
@MainActor
struct MediaDetailsPresentationTests {
    @Test
    func displayModelUsesAvailableMediaFieldsOnly() {
        let details = makeDetails(
            mediaType: .book,
            fullDescription: nil,
            explanation: nil
        )
        let model = MediaDetailsDisplayModel(details: details)

        #expect(model.title == "Arrival")
        #expect(!model.isFavorite)
        #expect(!model.isFavoriteSaving)
        #expect(model.originalTitle == nil)
        #expect(model.mediaType == L10n.Media.Details.book)
        #expect(model.fallbackSymbol == "book.closed.fill")
        #expect(model.description == "Short text")
        #expect(model.explanation == nil)
        #expect(model.facts.contains(L10n.Media.Details.pages(240)))
        #expect(model.tagGroups.map(\.title) == [
            L10n.Media.Details.genres,
            L10n.Media.Details.atmospheres
        ])
        #expect(model.tagGroups.map(\.symbol) == ["theatermasks.fill", "sparkles"])
        #expect(!model.artworkStartsBelowSafeArea)
        #expect(MediaDetailsDisplayModel(details: makeDetails(mediaType: .game)).artworkStartsBelowSafeArea)
    }

    @Test
    func favoriteButtonUpdatesWithoutReplacingItsAppearance() throws {
        let detailsView = MediaDetailsView(imageLoader: RemoteImageLoader())
        var model = MediaDetailsDisplayModel(details: makeDetails())
        let button = detailsView.favoriteButton

        detailsView.showContent(model)
        let icon = try #require(button.subviews.compactMap { $0 as? UIImageView }.first { $0.image != nil })
        #expect(button.configuration == nil)
        #expect(button.subviews.allSatisfy { !($0 is UIActivityIndicatorView) })
        #expect(button.accessibilityLabel == L10n.Media.Details.addToFavorites)

        model.isFavoriteSaving = true
        detailsView.showContent(model)
        #expect(button === detailsView.favoriteButton)
        #expect(button.configuration == nil)
        #expect(!icon.isHidden)
        #expect(!button.isEnabled)

        model.isFavoriteSaving = false
        model.isFavorite = true
        detailsView.showContent(model)
        #expect(button === detailsView.favoriteButton)
        #expect(button.configuration == nil)
        #expect(!icon.isHidden)
        #expect(button.isEnabled)
        #expect(button.accessibilityLabel == L10n.Media.Details.removeFromFavorites)
    }

    @Test
    func viewModelPassesSearchContextAndPublishesLoadedState() async {
        let repository = MediaDetailsRepositorySpy()
        let viewModel = MediaDetailsViewModel(
            context: MediaDetailsContext(mediaId: 5, searchSessionId: 101),
            repository: repository,
            favoriteRepository: FavoriteRepositorySpy(),
            analyticsTracker: MediaDetailsAnalyticsTrackerSpy()
        )

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if case .loaded = state { continuation.resume() }
            }
            viewModel.load()
            if case .loading = viewModel.state {} else { Issue.record("Expected loading state") }
            repository.complete(at: 0, with: .success(makeDetails()))
        }

        #expect(repository.requests.count == 1)
        #expect(repository.requests.first?.mediaId == 5)
        #expect(repository.requests.first?.searchSessionId == 101)
        guard case let .loaded(model) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(model.title == "Arrival")
        #expect(model.explanation == "Why it fits")
    }

    @Test
    func viewModelCanRetryAfterFailure() async {
        let repository = MediaDetailsRepositorySpy()
        let viewModel = MediaDetailsViewModel(
            context: MediaDetailsContext(mediaId: 5, searchSessionId: nil),
            repository: repository,
            favoriteRepository: FavoriteRepositorySpy(),
            analyticsTracker: MediaDetailsAnalyticsTrackerSpy()
        )

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if case .failed = state { continuation.resume() }
            }
            viewModel.load()
            repository.complete(at: 0, with: .failure(.statusCode(404)))
        }
        guard case let .failed(message) = viewModel.state else {
            Issue.record("Expected failure state")
            return
        }
        #expect(message == L10n.Error.httpStatus(404))

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if case .loaded = state { continuation.resume() }
            }
            viewModel.load()
            repository.complete(at: 1, with: .success(makeDetails()))
        }
        #expect(repository.requests.count == 2)
        #expect(repository.requests.last?.searchSessionId == nil)
    }

    @Test
    func viewModelIgnoresOlderResponseAfterReload() async {
        let repository = MediaDetailsRepositorySpy()
        let viewModel = MediaDetailsViewModel(
            context: MediaDetailsContext(mediaId: 5, searchSessionId: 101),
            repository: repository,
            favoriteRepository: FavoriteRepositorySpy(),
            analyticsTracker: MediaDetailsAnalyticsTrackerSpy()
        )

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if case .loaded = state { continuation.resume() }
            }
            viewModel.load()
            viewModel.load()
            repository.complete(at: 0, with: .failure(.unknown))
            repository.complete(at: 1, with: .success(makeDetails()))
        }

        guard case .loaded = viewModel.state else {
            Issue.record("Older failure replaced the latest result")
            return
        }
    }

    @Test
    func favoriteUsesServerStateAndIgnoresRepeatedTap() async {
        let repository = MediaDetailsRepositorySpy()
        let favorites = FavoriteRepositorySpy()
        let analytics = MediaDetailsAnalyticsTrackerSpy()
        let viewModel = MediaDetailsViewModel(
            context: MediaDetailsContext(mediaId: 5, searchSessionId: nil),
            repository: repository,
            favoriteRepository: favorites,
            analyticsTracker: analytics
        )
        await load(viewModel, from: repository)

        viewModel.toggleFavorite()
        viewModel.toggleFavorite()
        #expect(favorites.requests.count == 1)
        #expect(favorites.requests.first?.mediaId == 5)
        #expect(favorites.requests.first?.isFavorite == true)
        guard case let .loaded(saving) = viewModel.state else {
            Issue.record("Expected loaded state while saving")
            return
        }
        #expect(saving.isFavoriteSaving)
        #expect(!saving.isFavorite)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if case let .loaded(model) = state, !model.isFavoriteSaving { continuation.resume() }
            }
            favorites.complete(at: 0, with: .success(true))
        }
        guard case let .loaded(updated) = viewModel.state else {
            Issue.record("Expected updated loaded state")
            return
        }
        #expect(updated.isFavorite)
        #expect(analytics.events.map(\.name) == ["favorite_change_requested", "favorite_change_succeeded"])
        #expect(analytics.events.allSatisfy { $0.parameters["media_id"] == nil })
    }

    @Test
    func favoriteFailureRestoresButtonAndShowsError() async {
        let repository = MediaDetailsRepositorySpy()
        let favorites = FavoriteRepositorySpy()
        let analytics = MediaDetailsAnalyticsTrackerSpy()
        let viewModel = MediaDetailsViewModel(
            context: MediaDetailsContext(mediaId: 5, searchSessionId: nil),
            repository: repository,
            favoriteRepository: favorites,
            analyticsTracker: analytics
        )
        await load(viewModel, from: repository)
        var errorMessage: String?
        viewModel.onFavoriteError = { errorMessage = $0 }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if case let .loaded(model) = state, !model.isFavoriteSaving { continuation.resume() }
            }
            viewModel.toggleFavorite()
            favorites.complete(at: 0, with: .failure(.statusCode(500)))
        }

        guard case let .loaded(model) = viewModel.state else {
            Issue.record("Expected loaded state after failure")
            return
        }
        #expect(!model.isFavorite)
        #expect(!model.isFavoriteSaving)
        #expect(errorMessage == L10n.Error.httpStatus(500))
        #expect(analytics.events.map(\.name) == ["favorite_change_requested", "favorite_change_failed"])
        #expect(analytics.events.last?.parameters["error_category"] == .string("http_status"))
    }

    private func load(_ viewModel: MediaDetailsViewModel, from repository: MediaDetailsRepositorySpy) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            viewModel.onStateChange = { state in
                if case .loaded = state { continuation.resume() }
            }
            viewModel.load()
            repository.complete(at: 0, with: .success(makeDetails()))
        }
        viewModel.onStateChange = nil
    }

    private func makeDetails(
        mediaType: MediaType = .movie,
        fullDescription: String? = "Full text",
        explanation: String? = "Why it fits"
    ) -> MediaDetails {
        MediaDetails(
            mediaId: 5,
            title: "Arrival",
            originalTitle: "Arrival",
            mediaType: mediaType,
            releaseYear: 2016,
            imageUrl: nil,
            shortDescription: "Short text",
            fullDescription: fullDescription,
            rating: 8.1,
            durationMinutes: nil,
            seasonCount: nil,
            pageCount: mediaType == .book ? 240 : nil,
            estimatedHours: nil,
            ageRating: nil,
            genres: ["sci-fi"],
            atmosphereTags: ["thoughtful"],
            themeTags: [],
            platforms: [],
            explanation: explanation,
            warning: nil,
            isFavorite: false,
            progressStatus: nil,
            completionLabel: "Not marked yet",
            isHidden: false
        )
    }
}

private final class MediaDetailsRepositorySpy: MediaDetailsRepositoryProtocol {
    private(set) var requests: [(mediaId: Int, searchSessionId: Int?)] = []
    private var completions: [(Result<MediaDetails, APIError>) -> Void] = []

    func loadDetails(
        mediaId: Int,
        searchSessionId: Int?,
        completion: @escaping (Result<MediaDetails, APIError>) -> Void
    ) {
        requests.append((mediaId, searchSessionId))
        completions.append(completion)
    }

    func complete(at index: Int, with result: Result<MediaDetails, APIError>) {
        completions[index](result)
    }
}

private final class FavoriteRepositorySpy: FavoriteRepositoryProtocol {
    private(set) var requests: [(mediaId: Int, isFavorite: Bool)] = []
    private var completions: [(Result<Bool, APIError>) -> Void] = []

    func loadFavorites(completion: @escaping (Result<[FavoriteItem], APIError>) -> Void) {
        Issue.record("Media details must not load the favorites list")
        completion(.failure(.unknown))
    }

    func setFavorite(mediaId: Int, isFavorite: Bool, completion: @escaping (Result<Bool, APIError>) -> Void) {
        requests.append((mediaId, isFavorite))
        completions.append(completion)
    }

    func complete(at index: Int, with result: Result<Bool, APIError>) {
        completions[index](result)
    }
}

private final class MediaDetailsAnalyticsTrackerSpy: AnalyticsTrackerProtocol {
    private(set) var events: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        events.append(event)
    }
}
