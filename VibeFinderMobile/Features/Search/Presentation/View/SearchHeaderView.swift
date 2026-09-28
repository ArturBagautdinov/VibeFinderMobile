import UIKit

final class SearchHeaderView: UIView {
    private let avatarView = ProfileAvatarView()

    init(username: String) {
        super.init(frame: .zero)
        configure(username: username)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(avatar: ProfileAvatar?, initials: String) {
        avatarView.render(avatar: avatar, initials: initials)
    }

    private func configure(username: String) {
        let brandTitleView = makeBrandTitleView()

        avatarView.useCompactAppearance()
        avatarView.render(avatar: nil, initials: String(username.prefix(1)).uppercased())
        avatarView.accessibilityIdentifier = "search.avatar"
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        let avatarContainer = UIView()
        avatarContainer.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.18)
        avatarContainer.layer.cornerRadius = 23
        avatarContainer.layer.cornerCurve = .continuous
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.addSubview(avatarView)

        let stackView = UIStackView(arrangedSubviews: [brandTitleView, avatarContainer])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            avatarContainer.widthAnchor.constraint(equalToConstant: 46),
            avatarContainer.heightAnchor.constraint(equalToConstant: 46),
            avatarView.widthAnchor.constraint(equalToConstant: 36),
            avatarView.heightAnchor.constraint(equalToConstant: 36),
            avatarView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

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
