//
//  ProfileViewController.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 11.09.2026.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    
    private let viewModel: ProfileViewModel
    private lazy var profileView = ProfileView()
    
    var onLogout: (() -> Void)?
    var onEditProfileSelected: ((UserProfile) -> Void)?
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureActions()
        configureNavigation()
        viewModel.loadProfileIfNeeded()
    }
    
    private func bind() {
        profileView.render(viewModel.state)
        
        viewModel.onStateChange = { [weak self] state in
            self?.profileView.render(state)
        }
        
        viewModel.onLogout = { [weak self] in
            self?.onLogout?()
        }
    }
    
    private func configureActions() {
        profileView.onRetrySelected = { [weak self] in
            self?.viewModel.loadProfile()
        }
        
        profileView.onLogoutSelected = { [weak self] in
            self?.showLogoutConfirmation()
        }

        profileView.onEditProfileSelected = { [weak self] in
            guard let profile = self?.viewModel.editableProfile else { return }
            self?.onEditProfileSelected?(profile)
        }
    }

    func applyUpdatedProfile(_ profile: UserProfile) {
        viewModel.applyUpdatedProfile(profile)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: L10n.Profile.Logout.title,
            message: L10n.Profile.Logout.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Profile.Logout.action, style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        })
        present(alert, animated: true)
    }
    
    private func configureNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}
