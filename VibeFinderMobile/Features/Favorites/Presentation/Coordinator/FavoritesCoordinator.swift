import UIKit
import Swinject

final class FavoritesCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let container: Container

    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)

        let viewController = FavoritesViewController(
            viewModel: container.resolve(FavoritesViewModel.self)!,
            imageLoader: container.resolve(RemoteImageLoading.self)!
        )
        viewController.onFavoriteSelected = { [weak self] mediaId in
            self?.showMediaDetails(mediaId: mediaId)
        }
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showMediaDetails(mediaId: Int) {
        let context = MediaDetailsContext(mediaId: mediaId, searchSessionId: nil)
        let viewController = MediaDetailsViewController(
            viewModel: container.resolve(MediaDetailsViewModel.self, argument: context)!,
            imageLoader: container.resolve(RemoteImageLoading.self)!,
            backAccessibilityLabel: L10n.Favorites.backToList
        )
        viewController.onBackSelected = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}
