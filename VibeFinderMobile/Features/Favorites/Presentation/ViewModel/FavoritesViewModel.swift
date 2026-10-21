import Foundation

@MainActor
final class FavoritesViewModel {
    struct State {
        enum Content {
            case notLoaded
            case empty
            case items([FavoriteItem])
        }

        let content: Content
        let isLoading: Bool
        let errorMessage: String?
    }

    private let repository: FavoriteRepositoryProtocol
    private let analyticsTracker: AnalyticsTrackerProtocol
    private var requestGeneration = 0

    private(set) var state = State(content: .notLoaded, isLoading: false, errorMessage: nil) {
        didSet { onStateChange?(state) }
    }
    var onStateChange: ((State) -> Void)?

    init(repository: FavoriteRepositoryProtocol, analyticsTracker: AnalyticsTrackerProtocol) {
        self.repository = repository
        self.analyticsTracker = analyticsTracker
    }

    func loadFavorites() {
        requestGeneration += 1
        let generation = requestGeneration
        state = State(content: state.content, isLoading: true, errorMessage: nil)
        analyticsTracker.track(FavoritesAnalyticsEvent.loadRequested())

        repository.loadFavorites { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self, self.requestGeneration == generation else { return }

                switch result {
                case let .success(items):
                    self.state = State(
                        content: items.isEmpty ? .empty : .items(items),
                        isLoading: false,
                        errorMessage: nil
                    )
                    self.analyticsTracker.track(FavoritesAnalyticsEvent.loadSucceeded(count: items.count))
                case let .failure(error):
                    self.state = State(
                        content: self.state.content,
                        isLoading: false,
                        errorMessage: error.userMessage
                    )
                    self.analyticsTracker.track(FavoritesAnalyticsEvent.loadFailed(error: error))
                }
            }
        }
    }
}
