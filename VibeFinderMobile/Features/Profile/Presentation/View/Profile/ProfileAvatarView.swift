import UIKit

final class ProfileAvatarView: UIView {
    private let imageView = UIImageView()
    private let initialsLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(avatar: ProfileAvatar?, initials: String) {
        let backgroundColor = UIColor(hex: avatar?.backgroundHex ?? "")
            ?? AppTheme.Color.secondaryAccent
        let foregroundColor = UIColor(hex: avatar?.foregroundHex ?? "")
            ?? (avatar == nil ? AppTheme.Color.textPrimary : .white)

        self.backgroundColor = backgroundColor
        initialsLabel.text = initials
        initialsLabel.textColor = foregroundColor
        imageView.tintColor = foregroundColor

        if
            avatar?.style == .symbol,
            let symbol = avatar?.symbol,
            let image = UIImage(systemName: symbol)
        {
            imageView.image = image
            imageView.isHidden = false
            initialsLabel.isHidden = true
            accessibilityLabel = initials
        } else if avatar?.style == .color {
            imageView.image = nil
            imageView.isHidden = true
            initialsLabel.isHidden = true
            accessibilityLabel = initials
        } else {
            imageView.image = nil
            imageView.isHidden = true
            initialsLabel.isHidden = false
            accessibilityLabel = initials
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

    private func configure() {
        clipsToBounds = true
        isAccessibilityElement = true
        layer.cornerCurve = .continuous
        layer.borderWidth = 4
        layer.borderColor = AppTheme.Color.border.cgColor

        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 28,
            weight: .bold
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false

        initialsLabel.font = .systemFont(ofSize: 28, weight: .black)
        initialsLabel.textAlignment = .center
        initialsLabel.adjustsFontForContentSizeCategory = true
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(initialsLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.46),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            initialsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            initialsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 6),
            initialsLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -6)
        ])
    }
}
