//
//  ProfileNavigationHeaderView.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 14.09.2026.
//

import UIKit

final class ProfileNavigationHeaderView: UIView {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.96)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.35).cgColor
        layer.shadowColor = AppTheme.Color.primary.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
        accessibilityIdentifier = "profile.navigationHeader"

        titleLabel.text = L10n.Tab.profile
        titleLabel.font = .systemFont(ofSize: 18, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
