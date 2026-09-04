import UIKit

final class SearchStatusView: UIView {
    private let iconView = UIImageView()
    private let messageLabel = UILabel()

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
            return
        }

        messageLabel.text = message
        accessibilityLabel = message
        isHidden = false
    }

    private func configure() {
        isHidden = true
        accessibilityIdentifier = "search.errorView"
        backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemRed.withAlphaComponent(0.28).cgColor
        isAccessibilityElement = true

        iconView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iconView.tintColor = .systemRed
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.textColor = .systemRed
        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView(arrangedSubviews: [iconView, messageLabel])
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
