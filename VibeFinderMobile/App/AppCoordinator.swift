import UIKit
import Swinject

protocol Coordinator: AnyObject {
    func start()
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let container: Container
    private let navigationController = UINavigationController()
    private var childCoordinator: Coordinator?

    init(window: UIWindow, container: Container) {
        self.window = window
        self.container = container
    }

    func start() {
        configureNavigationBar()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showSearch(username: "Bro")
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppTheme.Color.background
        appearance.titleTextAttributes = [.foregroundColor: AppTheme.Color.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: AppTheme.Color.textPrimary]

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.tintColor = AppTheme.Color.accent
    }

    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            container: container
        )
        authCoordinator.onAuthenticated = { [weak self] username in
            self?.showSearch(username: username)
        }
        childCoordinator = authCoordinator
        authCoordinator.start()
    }

    private func showSearch(username: String) {
        childCoordinator = nil
        navigationController.setNavigationBarHidden(true, animated: true)
        let viewModel = container.resolve(SearchViewModel.self, argument: username)!
        let viewController = SearchViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: true)
    }
}
