import Foundation
import Testing
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
    func viewModelPassesSearchContextAndPublishesLoadedState() async {
        let repository = MediaDetailsRepositorySpy()
        let viewModel = MediaDetailsViewModel(
            context: MediaDetailsContext(mediaId: 5, searchSessionId: 101),
            repository: repository
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
            repository: repository
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
            repository: repository
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
