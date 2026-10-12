import Foundation

@MainActor
final class MediaDetailsViewModel {
    enum State {
        case idle
        case loading
        case loaded(MediaDetailsDisplayModel)
        case failed(String)
    }

    private let context: MediaDetailsContext
    private let repository: MediaDetailsRepositoryProtocol
    private let favoriteRepository: FavoriteRepositoryProtocol
    private let analyticsTracker: AnalyticsTrackerProtocol
    private var requestGeneration = 0

    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }
    var onStateChange: ((State) -> Void)?
    var onFavoriteError: ((String) -> Void)?

    init(
        context: MediaDetailsContext,
        repository: MediaDetailsRepositoryProtocol,
        favoriteRepository: FavoriteRepositoryProtocol,
        analyticsTracker: AnalyticsTrackerProtocol
    ) {
        self.context = context
        self.repository = repository
        self.favoriteRepository = favoriteRepository
        self.analyticsTracker = analyticsTracker
    }

    func load() {
        requestGeneration += 1
        let generation = requestGeneration
        state = .loading

        repository.loadDetails(
            mediaId: context.mediaId,
            searchSessionId: context.searchSessionId
        ) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self, self.requestGeneration == generation else { return }
                switch result {
                case let .success(details):
                    self.state = .loaded(MediaDetailsDisplayModel(details: details))
                case let .failure(error):
                    self.state = .failed(error.userMessage)
                }
            }
        }
    }

    func toggleFavorite() {
        guard case let .loaded(current) = state, !current.isFavoriteSaving else { return }

        let target = !current.isFavorite
        let generation = requestGeneration
        analyticsTracker.track(MediaFavoriteAnalyticsEvent.requested(isFavorite: target))

        var saving = current
        saving.isFavoriteSaving = true
        state = .loaded(saving)

        favoriteRepository.setFavorite(mediaId: context.mediaId, isFavorite: target) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self,
                      self.requestGeneration == generation,
                      case let .loaded(current) = self.state,
                      current.isFavoriteSaving else { return }

                var updated = current
                updated.isFavoriteSaving = false

                switch result {
                case let .success(isFavorite):
                    updated.isFavorite = isFavorite
                    self.state = .loaded(updated)
                    self.analyticsTracker.track(MediaFavoriteAnalyticsEvent.succeeded(isFavorite: target))
                case let .failure(error):
                    self.state = .loaded(updated)
                    self.analyticsTracker.track(MediaFavoriteAnalyticsEvent.failed(isFavorite: target, error: error))
                    self.onFavoriteError?(error.userMessage)
                }
            }
        }
    }
}
