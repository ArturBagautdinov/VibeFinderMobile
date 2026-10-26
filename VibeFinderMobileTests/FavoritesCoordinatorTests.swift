import Foundation
import Swinject
import Testing
import UIKit
@testable import VibeFinderMobile

@Suite
@MainActor
struct FavoritesCoordinatorTests {
    @Test
    func favoriteSelectionOpensDetailsWithoutSearchSessionAndBackReturnsToList() {
        let container = Container()
        let favoriteRepository = FavoriteRepositoryStub()
        let detailsRepository = MediaDetailsRepositorySpy()
        let analytics = FavoritesAnalyticsStub()
        let imageLoader = FavoritesImageLoaderStub()

        container.register(FavoritesViewModel.self) { _ in
            FavoritesViewModel(repository: favoriteRepository, analyticsTracker: analytics)
        }
        container.register(RemoteImageLoading.self) { _ in imageLoader }
        container.register(MediaDetailsViewModel.self) { _, context in
            MediaDetailsViewModel(
                context: context,
                repository: detailsRepository,
                favoriteRepository: favoriteRepository,
                analyticsTracker: analytics
            )
        }

        let navigationController = UINavigationController()
        let coordinator = FavoritesCoordinator(navigationController: navigationController, container: container)
        coordinator.start()

        guard let favorites = navigationController.viewControllers.first as? FavoritesViewController else {
            Issue.record("Expected Favorites root")
            return
        }

        favorites.onFavoriteSelected?(42)
        guard let details = navigationController.topViewController as? MediaDetailsViewController else {
            Issue.record("Expected Media Details after item selection")
            return
        }

        details.loadViewIfNeeded()
        #expect(detailsRepository.requestedMediaId == 42)
        #expect(detailsRepository.requestedSearchSessionId == nil)
        #expect(details.view.findView("media.details.backButton")?.accessibilityLabel == L10n.Favorites.backToList)

        details.onBackSelected?()
        #expect(navigationController.topViewController === favorites)
    }
}

private final class MediaDetailsRepositorySpy: MediaDetailsRepositoryProtocol {
    private(set) var requestedMediaId: Int?
    private(set) var requestedSearchSessionId: Int?

    func loadDetails(
        mediaId: Int,
        searchSessionId: Int?,
        completion: @escaping (Result<MediaDetails, APIError>) -> Void
    ) {
        requestedMediaId = mediaId
        requestedSearchSessionId = searchSessionId
    }
}

private final class FavoriteRepositoryStub: FavoriteRepositoryProtocol {
    func loadFavorites(completion: @escaping (Result<[FavoriteItem], APIError>) -> Void) {
        completion(.success([]))
    }

    func setFavorite(mediaId: Int, isFavorite: Bool, completion: @escaping (Result<Bool, APIError>) -> Void) {
        completion(.success(isFavorite))
    }
}

private final class FavoritesAnalyticsStub: AnalyticsTrackerProtocol {
    func track(_ event: AnalyticsEvent) {}
}

private final class FavoritesImageLoaderStub: RemoteImageLoading {
    func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        completion(nil)
        return nil
    }
}

private extension UIView {
    func findView(_ identifier: String) -> UIView? {
        if accessibilityIdentifier == identifier { return self }
        for subview in subviews {
            if let found = subview.findView(identifier) { return found }
        }
        return nil
    }
}
