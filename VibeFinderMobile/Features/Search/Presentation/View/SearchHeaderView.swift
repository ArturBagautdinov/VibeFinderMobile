import UIKit

final class SearchHeaderView: UIView {
    init(username: String) {
        super.init(frame: .zero)
        configure(username: username)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(username: String) {
        let brandTitleView = makeBrandTitleView()

        let avatarLabel = UILabel()
        avatarLabel.text = String(username.prefix(1)).uppercased()
        avatarLabel.font = .systemFont(ofSize: 17, weight: .black)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.backgroundColor = AppTheme.Color.secondaryAccent
        avatarLabel.layer.cornerRadius = 18
        avatarLabel.layer.cornerCurve = .continuous
        avatarLabel.clipsToBounds = true
        avatarLabel.accessibilityIdentifier = "search.avatar"
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false

        let avatarContainer = UIView()
        avatarContainer.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.18)
        avatarContainer.layer.cornerRadius = 23
        avatarContainer.layer.cornerCurve = .continuous
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.addSubview(avatarLabel)

        let stackView = UIStackView(arrangedSubviews: [brandTitleView, avatarContainer])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            avatarContainer.widthAnchor.constraint(equalToConstant: 46),
            avatarContainer.heightAnchor.constraint(equalToConstant: 46),
            avatarLabel.widthAnchor.constraint(equalToConstant: 36),
            avatarLabel.heightAnchor.constraint(equalToConstant: 36),
            avatarLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func makeBrandTitleView() -> UIStackView {
        let vibeLabel = makeBrandLabel(text: "Vibe", color: AppTheme.Color.primary)
        let finderLabel = makeBrandLabel(text: "Finder", color: AppTheme.Color.secondaryAccent)

        let stackView = UIStackView(arrangedSubviews: [vibeLabel, finderLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        stackView.accessibilityIdentifier = "search.brandTitleView"

        return stackView
    }

    private func makeBrandLabel(text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 32, weight: .black)
        label.textColor = color
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.layer.shadowColor = color.cgColor
        label.layer.shadowOpacity = 0.34
        label.layer.shadowRadius = 12
        label.layer.shadowOffset = .zero

        return label
    }
}
