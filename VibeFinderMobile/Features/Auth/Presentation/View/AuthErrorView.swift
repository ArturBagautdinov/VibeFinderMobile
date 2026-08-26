import UIKit

final class AuthErrorView: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMessage(_ message: String?) {
        guard let message, !message.isEmpty else {
            isHidden = true
            accessibilityLabel = nil
            isAccessibilityElement = false
            return
        }

        let lines = message
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map(String.init)

        titleLabel.text = lines.first ?? message
        detailsLabel.text = lines.dropFirst().joined(separator: "\n")
        detailsLabel.isHidden = lines.count <= 1
        accessibilityLabel = message
        isAccessibilityElement = true
        isHidden = false
    }

    private func configure() {
        isHidden = true
        accessibilityIdentifier = "auth.errorLabel"
        backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemRed.withAlphaComponent(0.28).cgColor

        iconView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iconView.tintColor = .systemRed
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize,
            weight: .semibold
        )
        titleLabel.textColor = .systemRed
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        detailsLabel.font = .preferredFont(forTextStyle: .footnote)
        detailsLabel.textColor = UIColor.systemRed.withAlphaComponent(0.86)
        detailsLabel.numberOfLines = 0
        detailsLabel.adjustsFontForContentSizeCategory = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(textStack)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            textStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
