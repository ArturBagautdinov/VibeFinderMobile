//
//  ProfileView.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 10.09.2026.
//

import Foundation
import UIKit

final class ProfileView: UIView {
    var onRetrySelected: (() -> Void)?
    var onLogoutSelected: (() -> Void)?
    var onEditProfileSelected: (() -> Void)?
    
    private let topBlurView = GradientBlurView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let statusView = SearchStatusView()
    private let loadingView = SearchLoadingView()
    private let navigationHeaderView = ProfileNavigationHeaderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(_ state: ProfileViewModel.State) {
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        statusView.setMessage(state.errorMessage)
        loadingView.setVisible(state.isLoading)
        
        if let profile = state.profile {
            let headerView = ProfileHeaderView(profile: profile)
            headerView.onEditSelected = { [weak self] in
                self?.onEditProfileSelected?()
            }
            contentStack.addArrangedSubview(headerView)
            contentStack.addArrangedSubview(ProfileStatsView(stats: profile.stats))
            contentStack.addArrangedSubview(ProfileTasteView(profile: profile))
            contentStack.addArrangedSubview(makeLogoutButton())
        } else if state.errorMessage != nil, !state.isLoading {
            contentStack.addArrangedSubview(makeRetryButton())
        }
    }
    
    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "profile.screen"
        
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentStack)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        navigationHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        topBlurView.translatesAutoresizingMaskIntoConstraints = false
        topBlurView.isUserInteractionEnabled = false
        topBlurView.alpha = 1
        
        addSubview(scrollView)
        addSubview(topBlurView)
        addSubview(navigationHeaderView)
        addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            topBlurView.topAnchor.constraint(equalTo: topAnchor),
            topBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBlurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBlurView.bottomAnchor.constraint(equalTo: navigationHeaderView.bottomAnchor, constant: 12),
            
            navigationHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            navigationHeaderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            navigationHeaderView.widthAnchor.constraint(equalToConstant: 130),
            navigationHeaderView.heightAnchor.constraint(equalToConstant: 40),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 76),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func makeLogoutButton() -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = L10n.Profile.Logout.action
        configuration.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = UIColor.systemRed.withAlphaComponent(0.16)
        configuration.baseForegroundColor = .systemRed
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 18,
            bottom: 0,
            trailing: 18
        )
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.22).cgColor
        
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        
        button.addAction(UIAction { [weak self] _ in
            self?.onLogoutSelected?()
        }, for: .touchUpInside)
        
        button.addAction(UIAction{ [weak self, weak button] _ in
            self?.setLogoutButton(button, isPressed: true)
        }, for: [.touchDown, .touchDragEnter])
        
        button.addAction(UIAction{ [weak self, weak button] _ in
            self?.setLogoutButton(button, isPressed: false)
        }, for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        
        
        return button
    }
    
    private func setLogoutButton(_ button: UIButton?, isPressed: Bool) {
        guard let button else { return }
        
        var configuration = button.configuration
        configuration?.baseBackgroundColor = UIColor.systemRed.withAlphaComponent(isPressed ? 0.24 : 0.16)
        button.configuration = configuration
        
        button.layer.borderColor = UIColor.systemRed
            .withAlphaComponent(isPressed ? 0.38 : 0.22)
            .cgColor
        
        UIView.animate(
            withDuration: 0.14,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            button.transform = isPressed
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
            
            button.alpha = isPressed ? 0.88 : 1
        }
        
    }
    
    private func makeRetryButton() -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = L10n.Common.retry
        configuration.baseBackgroundColor = AppTheme.Color.primary
        configuration.baseForegroundColor = AppTheme.Color.textPrimary
        configuration.cornerStyle = .capsule
        
        let button = UIButton(configuration: configuration)
        button.addAction(UIAction { [weak self] _ in
            self?.onRetrySelected?()
        }, for: .touchUpInside)
        return button
    }
    
    
}
