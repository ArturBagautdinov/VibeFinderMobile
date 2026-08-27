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
        restoreSession()
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

    private func restoreSession() {
        let authRepository = container.resolve(AuthRepositoryProtocol.self)!
        authRepository.refreshSession { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(session):
                    let username = session.displayName.isEmpty ? session.username : session.displayName
                    self?.showSearch(username: username)
                case .failure:
                    self?.showAuthFlow()
                }
            }
        }
    }

    private func showSearch(username: String) {
        childCoordinator = nil
        navigationController.setNavigationBarHidden(true, animated: true)
        let viewModel = container.resolve(SearchViewModel.self, argument: username)!
        let viewController = SearchViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: true)
    }
}
