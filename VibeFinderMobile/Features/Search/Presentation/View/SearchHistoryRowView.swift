import UIKit

final class SearchHistoryRowView: UIView {
    var onSelected: (() -> Void)?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(history: SearchHistoryEntryDisplayModel) {
        super.init(frame: .zero)
        configure()
        configure(with: history)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with history: SearchHistoryEntryDisplayModel) {
        titleLabel.text = history.title
        subtitleLabel.text = history.subtitle
        accessibilityLabel = history.title
    }

    private func configure() {
        backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.7)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.border.cgColor
        accessibilityIdentifier = "search.history.row"
        isAccessibilityElement = true
        accessibilityTraits = .button

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        addGestureRecognizer(tapGesture)

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
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 1

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 1

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }

    @objc private func rowTapped() {
        onSelected?()
    }
}
