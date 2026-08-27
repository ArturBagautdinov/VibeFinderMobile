import UIKit

final class RecentVibesView: UIView {
    private let recentVibes: [SearchViewModel.RecentVibe]

    init(recentVibes: [SearchViewModel.RecentVibe]) {
        self.recentVibes = recentVibes
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        let stackView = UIStackView(arrangedSubviews: [
            makeHeader(),
            makeList()
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func makeHeader() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = L10n.Search.Recent.title
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary

        let seeAllButton = UIButton(type: .system)
        seeAllButton.setTitle(L10n.Search.Recent.seeAll, for: .normal)
        seeAllButton.tintColor = AppTheme.Color.primary
        seeAllButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        seeAllButton.accessibilityIdentifier = "search.seeAllButton"

        let stackView = UIStackView(arrangedSubviews: [titleLabel, seeAllButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }

    private func makeList() -> UIStackView {
        let rows = recentVibes.map { vibe in
            RecentVibeRowView(vibe: vibe)
        }
        let stackView = UIStackView(arrangedSubviews: rows)
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }
}

private final class RecentVibeRowView: UIView {
    private let vibe: SearchViewModel.RecentVibe

    init(vibe: SearchViewModel.RecentVibe) {
        self.vibe = vibe
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.7)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.border.cgColor

        let clockContainer = makeClockContainer()
        let textStack = makeTextStack()

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = AppTheme.Color.textSecondary
        chevronView.contentMode = .scaleAspectFit
        chevronView.widthAnchor.constraint(equalToConstant: 16).isActive = true

        let rowStack = UIStackView(arrangedSubviews: [clockContainer, textStack, chevronView])
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 16
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            rowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func makeClockContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.18)
        container.layer.cornerRadius = 14
        container.layer.cornerCurve = .continuous
        container.translatesAutoresizingMaskIntoConstraints = false

        let clockView = UIImageView(image: UIImage(systemName: "clock"))
        clockView.tintColor = AppTheme.Color.primary
        clockView.contentMode = .scaleAspectFit
        clockView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(clockView)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 48),
            container.heightAnchor.constraint(equalToConstant: 48),
            clockView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            clockView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            clockView.widthAnchor.constraint(equalToConstant: 18),
            clockView.heightAnchor.constraint(equalToConstant: 18)
        ])

        return container
    }

    private func makeTextStack() -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = vibe.title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 1

        let subtitleLabel = UILabel()
        subtitleLabel.text = vibe.subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 1

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }
}
