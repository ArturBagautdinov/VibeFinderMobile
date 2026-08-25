import UIKit

final class FloatingBrandTitleView: UIView {
    private let vibeLabel = UILabel()
    private let finderLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startFloating() {
        startFloating(
            label: vibeLabel,
            key: "brand.vibe.float",
            yRange: (-5, 7),
            xRange: (-2, 2.5),
            duration: 2.6
        )
        startFloating(
            label: finderLabel,
            key: "brand.finder.float",
            yRange: (6, -5),
            xRange: (2.5, -2),
            duration: 2.9
        )
        startGlow()
    }

    private func configure() {
        isUserInteractionEnabled = false
        accessibilityIdentifier = "auth.brandTitleView"

        configure(label: vibeLabel, text: "Vibe", color: AppTheme.Color.primary)
        configure(label: finderLabel, text: "Finder", color: AppTheme.Color.secondaryAccent)

        let stackView = UIStackView(arrangedSubviews: [vibeLabel, finderLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12)
        ])
    }

    private func configure(label: UILabel, text: String, color: UIColor) {
        label.text = text
        label.font = .systemFont(ofSize: 42, weight: .black)
        label.textColor = color
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.layer.shadowColor = color.cgColor
        label.layer.shadowOpacity = 0.45
        label.layer.shadowRadius = 16
        label.layer.shadowOffset = .zero
    }

    private func startFloating(
        label: UILabel,
        key: String,
        yRange: (from: CGFloat, to: CGFloat),
        xRange: (from: CGFloat, to: CGFloat),
        duration: CFTimeInterval
    ) {
        guard label.layer.animation(forKey: key) == nil else {
            return
        }

        let vertical = CABasicAnimation(keyPath: "transform.translation.y")
        vertical.fromValue = yRange.from
        vertical.toValue = yRange.to

        let horizontal = CABasicAnimation(keyPath: "transform.translation.x")
        horizontal.fromValue = xRange.from
        horizontal.toValue = xRange.to

        let group = CAAnimationGroup()
        group.animations = [vertical, horizontal]
        group.duration = duration
        group.autoreverses = true
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        label.layer.add(group, forKey: key)
    }

    private func startGlow() {
        [vibeLabel, finderLabel].enumerated().forEach { index, label in
            let glow = CABasicAnimation(keyPath: "shadowOpacity")
            glow.fromValue = 0.22
            glow.toValue = 0.68
            glow.duration = 1.7 + CFTimeInterval(index) * 0.25
            glow.autoreverses = true
            glow.repeatCount = .infinity
            glow.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            label.layer.add(glow, forKey: "brand.glow.\(index)")
        }
    }
}
