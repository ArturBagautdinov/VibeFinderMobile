import UIKit

final class SearchSuggestionsPickerView: UIView {
    var onSuggestionSelected: ((SearchSuggestionDisplayModel) -> Void)?
    var onSuggestionDeleted: ((SearchSuggestionDisplayModel) -> Void)?
    var onRestoreDefaultsSelected: (() -> Void)?
    var onCloseSelected: (() -> Void)?

    private var suggestions: [SearchSuggestionDisplayModel]
    private let scrollView = UIScrollView()
    private let chipsStackView = UIStackView()

    init(suggestions: [SearchSuggestionDisplayModel]) {
        self.suggestions = suggestions
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "search.suggestionsPicker"

        let titleLabel = makeLabel(
            text: L10n.Search.Suggestions.All.title,
            font: .systemFont(ofSize: 28, weight: .black),
            color: AppTheme.Color.textPrimary
        )
        let subtitleLabel = makeLabel(
            text: L10n.Search.Suggestions.All.subtitle,
            font: .systemFont(ofSize: 16, weight: .medium),
            color: AppTheme.Color.textSecondary
        )
        subtitleLabel.numberOfLines = 0
        let restoreDefaultsButton = makeRestoreDefaultsButton()

        let closeButton = makeCloseButton()
        let headerStackView = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = 16
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        chipsStackView.axis = .vertical
        chipsStackView.spacing = 12
        chipsStackView.translatesAutoresizingMaskIntoConstraints = false

        render(suggestions)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(chipsStackView)

        let contentStackView = UIStackView(arrangedSubviews: [
            headerStackView,
            subtitleLabel,
            restoreDefaultsButton,
            scrollView
        ])
        contentStackView.axis = .vertical
        contentStackView.spacing = 14
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),

            contentStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            chipsStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            chipsStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            chipsStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            chipsStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            chipsStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    func render(_ suggestions: [SearchSuggestionDisplayModel]) {
        self.suggestions = suggestions
        chipsStackView.arrangedSubviews.forEach { view in
            chipsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        suggestions.map(makeSuggestionRow).forEach(chipsStackView.addArrangedSubview)
    }

    private func makeLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    private func makeCloseButton() -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "xmark")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        configuration.baseForegroundColor = AppTheme.Color.textPrimary
        configuration.background.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.72)
        configuration.background.strokeColor = AppTheme.Color.border
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 20

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "search.closeSuggestionsPickerButton"
        button.addAction(
            UIAction { [weak self] _ in
                self?.onCloseSelected?()
            },
            for: .touchUpInside
        )
        return button
    }

    private func makeSuggestionRow(_ suggestion: SearchSuggestionDisplayModel) -> UIView {
        let button = makeSuggestionButton(suggestion)
        let deleteButton = makeDeleteButton(suggestion)
        let rowStackView = UIStackView(arrangedSubviews: [button, deleteButton])
        rowStackView.axis = .horizontal
        rowStackView.alignment = .fill
        rowStackView.spacing = 10

        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 52)
        ])

        return rowStackView
    }

    private func makeRestoreDefaultsButton() -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = L10n.Search.Suggestion.restoreDefaults
        configuration.image = UIImage(systemName: "arrow.clockwise")
        configuration.imagePadding = 8
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        configuration.baseForegroundColor = AppTheme.Color.primary
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 16, bottom: 13, trailing: 16)
        configuration.background.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.12)
        configuration.background.strokeColor = AppTheme.Color.primary.withAlphaComponent(0.5)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 18

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "search.restoreDefaultSuggestionsButton"
        button.contentHorizontalAlignment = .center
        button.addAction(
            UIAction { [weak self] _ in
                self?.onRestoreDefaultsSelected?()
            },
            for: .touchUpInside
        )
        return button
    }

    private func makeSuggestionButton(_ suggestion: SearchSuggestionDisplayModel) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = suggestion.title
        configuration.titleLineBreakMode = .byTruncatingTail
        configuration.image = UIImage(systemName: "sparkle")
        configuration.imagePadding = 10
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        configuration.baseForegroundColor = AppTheme.Color.textPrimary
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 18, bottom: 15, trailing: 18)
        configuration.background.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.72)
        configuration.background.strokeColor = AppTheme.Color.primary.withAlphaComponent(0.45)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 18

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "search.suggestionsPickerChip"
        button.accessibilityValue = suggestion.title
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.addAction(
            UIAction { [weak self] _ in
                self?.onSuggestionSelected?(suggestion)
            },
            for: .touchUpInside
        )
        return button
    }

    private func makeDeleteButton(_ suggestion: SearchSuggestionDisplayModel) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "trash")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        configuration.baseForegroundColor = AppTheme.Color.accent
        configuration.background.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.72)
        configuration.background.strokeColor = AppTheme.Color.accent.withAlphaComponent(0.55)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 18

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "search.deleteSuggestionButton"
        button.accessibilityLabel = L10n.Search.Suggestion.delete
        button.addAction(
            UIAction { [weak self] _ in
                self?.onSuggestionDeleted?(suggestion)
            },
            for: .touchUpInside
        )
        return button
    }
}
