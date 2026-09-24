//
//  ProfileStatsView.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 10.09.2026.
//

import Foundation
import UIKit

final class ProfileStatsView: UIView {
    
    init(stats: [ProfileStatDisplayModel]) {
        super.init(frame: .zero)
        configure(stats)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(_ stats: [ProfileStatDisplayModel]) {
        let stack = UIStackView(arrangedSubviews: stats.map(makeStatView))
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    
    }
    
    private func makeStatView(_ stat: ProfileStatDisplayModel) -> UIView {
        
        let valueLabel = UILabel()
        valueLabel.text = stat.value
        valueLabel.font = .systemFont(ofSize: 24, weight: .black)
        valueLabel.textColor = AppTheme.Color.textPrimary
        valueLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = stat.title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = AppTheme.Color.textSecondary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 8, bottom: 14, trailing: 8)
        stack.backgroundColor = AppTheme.Color.surface
        stack.layer.cornerRadius = 18
        stack.layer.cornerCurve = .continuous
        stack.layer.borderWidth = 1
        stack.layer.borderColor = AppTheme.Color.border.cgColor
        return stack
    }
}
