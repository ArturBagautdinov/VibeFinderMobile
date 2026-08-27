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
        let brandLabel = UILabel()
        brandLabel.text = L10n.Search.brand
        brandLabel.font = .systemFont(ofSize: 30, weight: .black)
        brandLabel.textColor = AppTheme.Color.textPrimary
        brandLabel.adjustsFontForContentSizeCategory = true

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

        let stackView = UIStackView(arrangedSubviews: [brandLabel, avatarContainer])
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
}
