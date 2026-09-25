//
//  ProfileHeaderView.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 10.09.2026.
//

import Foundation
import UIKit

final class ProfileHeaderView: UIView {
    
    var onEditSelected: (() -> Void)?
    
    init(profile: ProfileDisplayModel) {
        super.init(frame: .zero)
        configure(profile)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(_ profile: ProfileDisplayModel) {
        
        let avatarView = ProfileAvatarView()
        avatarView.render(avatar: profile.avatar, initials: profile.initials)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = profile.displayName
        nameLabel.font = .systemFont(ofSize: 30, weight: .black)
        nameLabel.textColor = AppTheme.Color.textPrimary
        nameLabel.textAlignment = .center
        
        let usernameLabel = UILabel()
        usernameLabel.text = profile.username
        usernameLabel.font = .preferredFont(forTextStyle: .headline)
        usernameLabel.textAlignment = .center
        usernameLabel.textColor = AppTheme.Color.primary
        
        let emailLabel = UILabel()
        emailLabel.text = profile.email
        emailLabel.font = .preferredFont(forTextStyle: .subheadline)
        emailLabel.textColor = AppTheme.Color.textSecondary
        emailLabel.textAlignment = .center
        
        let statusLabel = UILabel()
        statusLabel.text = profile.emailStatus
        statusLabel.font = .preferredFont(forTextStyle: .caption1)
        statusLabel.textColor = AppTheme.Color.secondaryAccent
        statusLabel.textAlignment = .center
        
        let editButton = makeEditButton()
        
        let avatarStack = UIStackView(arrangedSubviews: [avatarView, usernameLabel])
        avatarStack.axis = .vertical
        avatarStack.spacing = 6
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, statusLabel, emailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let rootStack = UIStackView(arrangedSubviews: [avatarStack, textStack, editButton])
        rootStack.axis = .horizontal
        rootStack.alignment = .center
        rootStack.spacing = 14
        rootStack.backgroundColor = AppTheme.Color.surface
        rootStack.isLayoutMarginsRelativeArrangement = true
        rootStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        rootStack.layer.cornerRadius = 24
        rootStack.layer.cornerCurve = .continuous
        rootStack.layer.borderWidth = 1
        rootStack.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.3).cgColor
        rootStack.layer.shadowColor = AppTheme.Color.primary.cgColor
        rootStack.layer.shadowOpacity = 0.18
        rootStack.layer.shadowRadius = 4
        rootStack.layer.shadowOffset = CGSize(width: 6, height: 6)
        
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(rootStack)
        
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 68),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor),
            
            rootStack.topAnchor.constraint(equalTo: topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func makeEditButton() -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "pencil")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        configuration.baseBackgroundColor = AppTheme.Color.primary.withAlphaComponent(0.18)
        configuration.baseForegroundColor = AppTheme.Color.primary
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "profile.editButton"
        button.layer.borderColor = AppTheme.Color.primary.cgColor
        button.layer.borderWidth = 1
        
        button.addAction(
            UIAction { [weak self] _ in
                self?.onEditSelected?()
            }, for: .touchUpInside
        )
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 42),
            button.heightAnchor.constraint(equalTo: button.widthAnchor)
        ])
        return button
    }
}
