import UIKit

final class SearchSuggestionsView: UIScrollView {
    var onSuggestionSelected: ((String) -> Void)?

    private enum Animation {
        static let highlightDuration: TimeInterval = 0.22
        static let highlightedDelay: TimeInterval = 0.45
    }

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
            stackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor),
            heightAnchor.constraint(equalToConstant: 38)
        ])
    }

    private func makeSuggestionChip(_ title: String) -> UIButton {
        let button = UIButton(configuration: makeSuggestionConfiguration(title: title, isHighlighted: false))
        button.accessibilityIdentifier = "search.suggestionChip"
        button.addAction(
            UIAction { [weak self, weak button] _ in
                guard let self else { return }
                if let button {
                    self.highlightSuggestionChip(button, title: title)
                }
                self.onSuggestionSelected?(title)
            },
            for: .touchUpInside
        )
        return button
    }

    private func makeSuggestionConfiguration(title: String, isHighlighted: Bool) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.baseForegroundColor = isHighlighted ? .white : AppTheme.Color.textPrimary
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 20, bottom: 11, trailing: 20)
        configuration.background.backgroundColor = isHighlighted
            ? AppTheme.Color.primary.withAlphaComponent(0.95)
            : AppTheme.Color.surface.withAlphaComponent(0.55)
        configuration.background.strokeColor = isHighlighted
            ? AppTheme.Color.secondaryAccent.withAlphaComponent(0.85)
            : AppTheme.Color.primary.withAlphaComponent(0.55)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 24
        return configuration
    }

    private func highlightSuggestionChip(_ button: UIButton, title: String) {
        UIView.animate(
            withDuration: Animation.highlightDuration,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.2,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            button.configuration = self.makeSuggestionConfiguration(title: title, isHighlighted: true)
            button.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            button.layer.shadowColor = AppTheme.Color.primary.cgColor
            button.layer.shadowOpacity = 0.32
            button.layer.shadowRadius = 14
            button.layer.shadowOffset = CGSize(width: 0, height: 8)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.highlightedDelay) { [weak self, weak button] in
            guard let self, let button else { return }

            UIView.animate(
                withDuration: Animation.highlightDuration,
                delay: 0,
                options: [.beginFromCurrentState, .allowUserInteraction]
            ) {
                button.configuration = self.makeSuggestionConfiguration(title: title, isHighlighted: false)
                button.transform = .identity
                button.layer.shadowOpacity = 0
                button.layer.shadowRadius = 0
                button.layer.shadowOffset = .zero
            }
        }
    }
}
