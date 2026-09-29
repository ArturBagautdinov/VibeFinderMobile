//
//  GradientBlurView.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 14.09.2026.
//

import Foundation
import UIKit

final class GradientBlurView: UIView {
    private let blurView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemChromeMaterialDark)
    )
    private let dimView = UIView()
    private let gradientMaskLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientMaskLayer.frame = bounds
    }

    private func configure() {
        isUserInteractionEnabled = false
        backgroundColor = .clear

        blurView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = AppTheme.Color.background
        dimView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(blurView)
        addSubview(dimView)

        gradientMaskLayer.colors = [
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0.86).cgColor,
            UIColor.black.withAlphaComponent(0.72).cgColor,
            UIColor.black.withAlphaComponent(0.52).cgColor,
            UIColor.black.withAlphaComponent(0.30).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor
        ]

        gradientMaskLayer.locations = [0, 0.50, 0.64, 0.76, 0.86, 0.94, 1]
        gradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 1)

        layer.mask = gradientMaskLayer

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
