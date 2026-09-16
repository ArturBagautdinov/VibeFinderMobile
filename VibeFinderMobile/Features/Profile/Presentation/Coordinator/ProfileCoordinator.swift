//
//  ProfileCoordinator.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 11.09.2026.
//

import Foundation
import UIKit
import Swinject

final class ProfileCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private let container: Container
    
    var onLogout: (() -> Void)?
    
    init(
        navigationController: UINavigationController,
        container: Container
    ) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let viewController = ProfileViewController(
            viewModel: container.resolve(ProfileViewModel.self)!
        )
        viewController.onLogout = { [weak self] in
            self?.onLogout?()
        }
        navigationController.setViewControllers([viewController], animated: true)
    }
}
