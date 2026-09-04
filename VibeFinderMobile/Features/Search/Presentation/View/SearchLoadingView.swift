import UIKit

final class SearchLoadingView: UIView {
    private let glowView = UIView()
    private let iconContainer = UIView()
    private let iconView = UIImageView(image: UIImage(systemName: "sparkles"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let orbitLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setVisible(_ isVisible: Bool) {
        guard isHidden == isVisible || alpha != (isVisible ? 1 : 0) else {
            return
        }

        if isVisible {
            isHidden = false
            startAnimating()
        }

        UIView.animate(
            withDuration: 0.26,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            self.alpha = isVisible ? 1 : 0
        } completion: { _ in
            self.isHidden = !isVisible
            if !isVisible {
                self.stopAnimating()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        glowView.layer.cornerRadius = glowView.bounds.width / 2
        iconContainer.layer.cornerRadius = iconContainer.bounds.width / 2
        updateOrbitPath()
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background.withAlphaComponent(0.94)
        alpha = 0
        isHidden = true
        accessibilityIdentifier = "search.loadingView"

        configureGlow()
        configureIcon()
        configureLabels()

        let stackView = UIStackView(arrangedSubviews: [iconContainer, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(glowView)
        addSubview(stackView)
        glowView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            glowView.centerXAnchor.constraint(equalTo: centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -42),
            glowView.widthAnchor.constraint(equalToConstant: 220),
            glowView.heightAnchor.constraint(equalTo: glowView.widthAnchor),

            iconContainer.widthAnchor.constraint(equalToConstant: 86),
            iconContainer.heightAnchor.constraint(equalTo: iconContainer.widthAnchor),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -28)
        ])
    }

    private func configureGlow() {
        glowView.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.16)
        glowView.layer.shadowColor = AppTheme.Color.primary.cgColor
        glowView.layer.shadowOpacity = 0.55
        glowView.layer.shadowRadius = 46
        glowView.layer.shadowOffset = .zero
    }

    private func configureIcon() {
        iconContainer.backgroundColor = AppTheme.Color.surface
        iconContainer.layer.borderWidth = 1
        iconContainer.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.45).cgColor
        iconContainer.layer.shadowColor = AppTheme.Color.primary.cgColor
        iconContainer.layer.shadowOpacity = 0.45
        iconContainer.layer.shadowRadius = 24
        iconContainer.layer.shadowOffset = CGSize(width: 0, height: 12)

        orbitLayer.strokeColor = AppTheme.Color.secondaryAccent.withAlphaComponent(0.75).cgColor
        orbitLayer.fillColor = UIColor.clear.cgColor
        orbitLayer.lineWidth = 2
        orbitLayer.lineCap = .round
        orbitLayer.strokeEnd = 0.72
        iconContainer.layer.addSublayer(orbitLayer)

        iconView.tintColor = AppTheme.Color.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 34),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor)
        ])
    }

    private func configureLabels() {
        titleLabel.text = L10n.Search.Loading.title
        titleLabel.font = .systemFont(ofSize: 28, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true

        subtitleLabel.text = L10n.Search.Loading.subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true
    }

    private func updateOrbitPath() {
        let rect = iconContainer.bounds.insetBy(dx: 9, dy: 9)
        orbitLayer.path = UIBezierPath(ovalIn: rect).cgPath
    }

    private func startAnimating() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 0.92
        pulse.toValue = 1.08
        pulse.duration = 1.3
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        glowView.layer.add(pulse, forKey: "loading.pulse")

        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1.8
        rotation.repeatCount = .infinity
        orbitLayer.add(rotation, forKey: "loading.orbit")

        UIView.animate(
            withDuration: 1.15,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut]
        ) {
            self.iconView.transform = CGAffineTransform(scaleX: 1.12, y: 1.12).rotated(by: 0.08)
        }
    }

    private func stopAnimating() {
        glowView.layer.removeAnimation(forKey: "loading.pulse")
        orbitLayer.removeAnimation(forKey: "loading.orbit")
        iconView.layer.removeAllAnimations()
        iconView.transform = .identity
    }
}
