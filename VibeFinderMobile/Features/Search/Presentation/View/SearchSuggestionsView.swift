import UIKit

final class SearchSuggestionsView: UIScrollView {
    init(suggestions: [String]) {
        super.init(frame: .zero)
        configure(suggestions: suggestions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(suggestions: [String]) {
        showsHorizontalScrollIndicator = false

        let stackView = UIStackView(arrangedSubviews: suggestions.map(makeSuggestionChip))
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor),
            heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    private func makeSuggestionChip(_ title: String) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.baseForegroundColor = AppTheme.Color.textPrimary
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 20, bottom: 11, trailing: 20)
        configuration.background.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.55)
        configuration.background.strokeColor = AppTheme.Color.primary.withAlphaComponent(0.55)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 24

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "search.suggestionChip"
        return button
    }
}
