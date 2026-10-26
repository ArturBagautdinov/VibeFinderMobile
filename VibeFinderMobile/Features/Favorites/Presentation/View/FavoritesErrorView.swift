import UIKit

final class FavoritesErrorView: UIView {
    var onRetrySelected: (() -> Void)?

    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMessage(_ message: String?, isLoading: Bool) {
        isHidden = message == nil
        messageLabel.text = message
        retryButton.isEnabled = !isLoading
    }

    private func configure() {
        isHidden = true
        backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.82)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemRed.withAlphaComponent(0.35).cgColor
        accessibilityIdentifier = "favorites.error"

        let iconView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        iconView.tintColor = .systemRed
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let titleLabel = UILabel()
        titleLabel.text = L10n.Favorites.Error.title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true

        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.textColor = AppTheme.Color.textSecondary
        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true

        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.title = L10n.Common.retry
        buttonConfiguration.baseBackgroundColor = AppTheme.Color.primary.withAlphaComponent(0.18)
        buttonConfiguration.baseForegroundColor = AppTheme.Color.primary
        buttonConfiguration.cornerStyle = .capsule
        retryButton.configuration = buttonConfiguration
        retryButton.accessibilityIdentifier = "favorites.retry"
        retryButton.addAction(UIAction { [weak self] _ in
            self?.onRetrySelected?()
        }, for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, retryButton])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 10

        let row = UIStackView(arrangedSubviews: [iconView, textStack])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
    }
}
