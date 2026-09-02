import UIKit

final class SearchHistoryEmptyView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.58)
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.28).cgColor
        layer.shadowColor = AppTheme.Color.primary.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)
        accessibilityIdentifier = "search.recentHistoryEmptyView"

        let iconContainer = makeIconContainer()
        let iconView = makeIconView()
        let textStackView = makeTextStackView()

        iconContainer.addSubview(iconView)

        let stackView = UIStackView(arrangedSubviews: [iconContainer, textStackView])
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 56),
            iconContainer.heightAnchor.constraint(equalToConstant: 56),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func makeIconContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.2)
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.Color.secondaryAccent.withAlphaComponent(0.34).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func makeIconView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "sparkle.magnifyingglass"))
        imageView.tintColor = AppTheme.Color.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func makeTextStackView() -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = L10n.Search.Recent.emptyTitle
        titleLabel.font = .systemFont(ofSize: 18, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 1

        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.Search.Recent.emptySubtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }
}
