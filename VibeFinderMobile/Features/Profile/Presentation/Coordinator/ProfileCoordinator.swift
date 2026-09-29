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
    var onAppearanceChanged: ((ProfileAvatar?, String) -> Void)?
    
    init(
        navigationController: UINavigationController,
        container: Container
    ) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let viewModel = container.resolve(ProfileViewModel.self)!
        viewModel.onProfileChanged = { [weak self] profile in
            self?.onAppearanceChanged?(profile.avatar, profile.initials)
        }
        let viewController = ProfileViewController(
            viewModel: viewModel
        )
        viewController.onLogout = { [weak self] in
            self?.onLogout?()
        }
        viewController.onEditProfileSelected = { [weak self, weak viewController] profile in
            guard let self, let viewController else { return }
            let editor = EditProfileViewController(
                viewModel: self.container.resolve(EditProfileViewModel.self, argument: profile)!
            )
            editor.onClose = { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
            editor.onSaved = { [weak self, weak viewController] updatedProfile in
                viewController?.applyUpdatedProfile(updatedProfile)
                self?.navigationController.popViewController(animated: true)
            }
            self.navigationController.pushViewController(editor, animated: true)
        }
        navigationController.setViewControllers([viewController], animated: true)
        viewModel.loadProfileIfNeeded()
    }
}
