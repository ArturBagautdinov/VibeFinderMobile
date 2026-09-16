//
//  ProfileTasteView.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 10.09.2026.
//

import Foundation
import UIKit

final class ProfileTasteView: UIView {
    
    init(profile: ProfileDisplayModel) {
        super.init(frame: .zero)
        configure(profile)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(_ profile: ProfileDisplayModel) {
        
        let titleLabel = UILabel()
        titleLabel.text = L10n.Profile.tasteTitle
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, makeSummaryCard(profile.summary)])
        stack.axis = .vertical
        stack.spacing = 16
        
        stack.addArrangedSubview(ProfileTasteSectionsView(sections: profile.sections))
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    private func makeSummaryCard(_ summary: String) -> UIView {
        
        let iconView = UIImageView(image: UIImage(systemName: "quote.opening"))
        iconView.tintColor = AppTheme.Color.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = L10n.Profile.summaryTitle
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        
        let summaryLabel = UILabel()
        summaryLabel.text = summary
        summaryLabel.font = .preferredFont(forTextStyle: .body)
        summaryLabel.textColor = AppTheme.Color.textSecondary
        summaryLabel.numberOfLines = 0
        summaryLabel.adjustsFontForContentSizeCategory = true
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, summaryLabel])
        textStack.axis = .vertical
        textStack.spacing = 8
        
        let contentStack = UIStackView(arrangedSubviews: [iconView, textStack])
        contentStack.axis = .horizontal
        contentStack.spacing = 12
        contentStack.alignment = .top
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)
        
        let cardView = UIView()
        cardView.backgroundColor = AppTheme.Color.surface
        cardView.layer.cornerRadius = 24
        cardView.layer.cornerCurve = .continuous
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.28).cgColor
        cardView.layer.shadowColor = AppTheme.Color.primary.cgColor
        cardView.layer.shadowOpacity = 0.18
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOffset = CGSize(width: 6, height: 6)
        
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
            
        ])
        
        return cardView
            
        
        
    }
}

final class PaddingLabel: UILabel {
    
    var insets = UIEdgeInsets.zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}
