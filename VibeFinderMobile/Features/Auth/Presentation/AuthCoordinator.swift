import UIKit
import Swinject

final class AuthCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let container: Container

    var onAuthenticated: ((String) -> Void)?

    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        showLogin(direction: nil)
    }

    private func showLogin(direction: TransitionDirection?, completion: (() -> Void)? = nil) {
        let viewModel = container.resolve(LoginViewModel.self)!
        viewModel.onAuthenticated = { [weak self] session in
            self?.onAuthenticated?(session.displayName.isEmpty ? session.username : session.displayName)
        }
        let viewController = LoginViewController(viewModel: viewModel)
        viewController.onRegisterSelected = { [weak self] in
            self?.showRegister()
        }
        setRoot(viewController, direction: direction, completion: completion)
    }

    private func showRegister() {
        let viewModel = container.resolve(RegisterViewModel.self)!
        viewModel.onRegistered = { [weak self] message in
            self?.showLoginWithSuccess(message: message)
        }
        let viewController = RegisterViewController(viewModel: viewModel)
        viewController.onLoginSelected = { [weak self] in
            self?.showLogin(direction: .backward)
        }
        setRoot(viewController, direction: .forward)
    }

    private func showLoginWithSuccess(message: String) {
        showLogin(direction: .backward) { [weak self] in
            guard let loginViewController = self?.navigationController.viewControllers.first as? LoginViewController else {
                return
            }
            loginViewController.showSuccess(message)
        }
    }

    private func setRoot(
        _ viewController: UIViewController,
        direction: TransitionDirection?,
        completion: (() -> Void)? = nil
    ) {
        guard let direction else {
            navigationController.setViewControllers([viewController], animated: false)
            completion?()
            return
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        let transition = CATransition()
        transition.duration = 0.38
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = direction == .forward ? .fromRight : .fromLeft
        navigationController.view.layer.add(transition, forKey: "auth.transition")
        navigationController.setViewControllers([viewController], animated: false)

        CATransaction.commit()
    }
}

private enum TransitionDirection {
    case forward
    case backward
}
