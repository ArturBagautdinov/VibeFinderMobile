import UIKit

final class MediaDetailsPosterFadeView: UIView {
    enum Edge {
        case top
        case bottom
    }

    private let edge: Edge
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let blurMask = CAGradientLayer()
    private let backgroundGradient = CAGradientLayer()

    init(edge: Edge = .bottom) {
        self.edge = edge
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurMask.frame = blurView.bounds
        backgroundGradient.frame = bounds
        updateBackgroundColors()
    }

    private func configure() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (view: MediaDetailsPosterFadeView, _) in
            view.updateBackgroundColors()
        }

        blurMask.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.18).cgColor,
            UIColor.black.withAlphaComponent(0.78).cgColor,
            UIColor.black.cgColor
        ]
        blurMask.locations = [0, 0.28, 0.7, 1]
        blurView.layer.mask = blurMask

        backgroundGradient.locations = [0, 0.36, 0.76, 1]
        if edge == .top {
            blurMask.startPoint = CGPoint(x: 0.5, y: 1)
            blurMask.endPoint = CGPoint(x: 0.5, y: 0)
            backgroundGradient.startPoint = CGPoint(x: 0.5, y: 1)
            backgroundGradient.endPoint = CGPoint(x: 0.5, y: 0)
        }

        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        layer.addSublayer(backgroundGradient)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func updateBackgroundColors() {
        let background = AppTheme.Color.background.resolvedColor(with: traitCollection)
        backgroundGradient.colors = [
            background.withAlphaComponent(0).cgColor,
            background.withAlphaComponent(0.08).cgColor,
            background.withAlphaComponent(0.74).cgColor,
            background.cgColor
        ]
    }
}
