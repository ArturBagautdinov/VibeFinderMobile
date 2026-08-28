import UIKit
import Swinject

final class SearchCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let container: Container
    private let username: String

    init(
        navigationController: UINavigationController,
        container: Container,
        username: String
    ) {
        self.navigationController = navigationController
        self.container = container
        self.username = username
    }

    func start() {
        let viewModel = container.resolve(SearchViewModel.self, argument: username)!
        let viewController = SearchViewController(viewModel: viewModel)
        viewController.onResultsReady = { [weak self] page in
            self?.showResults(page)
        }
        navigationController.setViewControllers([viewController], animated: true)
    }

    private func showResults(_ page: SearchPage) {
        let viewController = SearchResultsViewController(
            page: page,
            imageLoader: container.resolve(SearchResultImageLoading.self)!
        )
        viewController.onBackSelected = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}
