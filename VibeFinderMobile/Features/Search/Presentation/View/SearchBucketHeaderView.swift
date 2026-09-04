import UIKit

final class SearchBucketHeaderView: UICollectionReusableView {
    private let accentLineView = UIView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let textStackView = UIStackView()
    private let contentStackView = UIStackView()
    private var hasAnimatedAppearance = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hasAnimatedAppearance = false
        stopIconFloating()
        resetAppearanceState()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopIconFloating()
            return
        }

        startIconFloating()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        startIconFloating()
    }

    func configure(with section: SearchResultsSectionIdentifier) {
        titleLabel.text = section.title
        descriptionLabel.text = section.description
        descriptionLabel.isHidden = section.description.isEmpty
    }

    func animateAppearanceIfNeeded() {
        startIconFloating()
        guard !hasAnimatedAppearance else { return }
        animateAppearance()
    }

    private func configure() {
        alpha = 1
        transform = .identity

        accentLineView.backgroundColor = AppTheme.Color.primary
        accentLineView.layer.cornerRadius = 2
        accentLineView.layer.cornerCurve = .continuous
        accentLineView.layer.shadowColor = AppTheme.Color.primary.cgColor
        accentLineView.layer.shadowOpacity = 0.45
        accentLineView.layer.shadowRadius = 10
        accentLineView.layer.shadowOffset = .zero
        accentLineView.translatesAutoresizingMaskIntoConstraints = false

        iconContainerView.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.16)
        iconContainerView.layer.cornerRadius = 16
        iconContainerView.layer.cornerCurve = .continuous
        iconContainerView.layer.borderWidth = 1
        iconContainerView.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.28).cgColor
        iconContainerView.layer.shadowColor = AppTheme.Color.primary.cgColor
        iconContainerView.layer.shadowOpacity = 0.18
        iconContainerView.layer.shadowRadius = 14
        iconContainerView.layer.shadowOffset = CGSize(width: 0, height: 6)
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.image = UIImage(systemName: "sparkles")
        iconImageView.tintColor = AppTheme.Color.secondaryAccent
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 26, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.layer.shadowColor = AppTheme.Color.primary.cgColor
        titleLabel.layer.shadowOpacity = 0.14
        titleLabel.layer.shadowRadius = 10
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)

        descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = AppTheme.Color.textSecondary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.adjustsFontForContentSizeCategory = true

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        textStackView.axis = .vertical
        textStackView.spacing = 5

        iconContainerView.addSubview(iconImageView)

        contentStackView.addArrangedSubview(accentLineView)
        contentStackView.addArrangedSubview(iconContainerView)
        contentStackView.addArrangedSubview(textStackView)
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 12
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),

            accentLineView.widthAnchor.constraint(equalToConstant: 4),
            accentLineView.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),

            iconContainerView.widthAnchor.constraint(equalToConstant: 32),
            iconContainerView.heightAnchor.constraint(equalTo: iconContainerView.widthAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
        ])

        resetAppearanceState()
    }

    private func animateAppearance() {
        hasAnimatedAppearance = true
        resetAppearanceState()

        UIView.animate(
            withDuration: 0.55,
            delay: 0.1,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.45,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.contentStackView.alpha = 1
            self.contentStackView.transform = .identity
        }

        iconContainerView.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        UIView.animate(
            withDuration: 0.7,
            delay: 0.18,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.35,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.iconContainerView.transform = .identity
        }
    }

    private func resetAppearanceState() {
        contentStackView.alpha = 0
        contentStackView.transform = CGAffineTransform(translationX: -14, y: 10)
    }

    private func startIconFloating() {
        guard iconContainerView.layer.animation(forKey: AnimationKey.float) == nil else {
            return
        }

        let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatAnimation.fromValue = -5
        floatAnimation.toValue = 5
        floatAnimation.duration = 1.8
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let driftAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        driftAnimation.fromValue = -1
        driftAnimation.toValue = 1
        driftAnimation.duration = 2.4
        driftAnimation.autoreverses = true
        driftAnimation.repeatCount = .infinity
        driftAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.fromValue = 0.14
        glowAnimation.toValue = 0.32
        glowAnimation.duration = 1.8
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        iconContainerView.layer.add(floatAnimation, forKey: AnimationKey.float)
        iconContainerView.layer.add(driftAnimation, forKey: AnimationKey.drift)
        iconContainerView.layer.add(glowAnimation, forKey: AnimationKey.glow)
    }

    private func stopIconFloating() {
        iconContainerView.layer.removeAnimation(forKey: AnimationKey.float)
        iconContainerView.layer.removeAnimation(forKey: AnimationKey.drift)
        iconContainerView.layer.removeAnimation(forKey: AnimationKey.glow)
    }
}

private enum AnimationKey {
    static let float = "searchBucketHeader.icon.float"
    static let drift = "searchBucketHeader.icon.drift"
    static let glow = "searchBucketHeader.icon.glow"
}
