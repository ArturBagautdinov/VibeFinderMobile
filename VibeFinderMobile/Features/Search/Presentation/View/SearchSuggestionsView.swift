import UIKit

final class SearchSuggestionsView: UIScrollView {
    var onSuggestionSelected: ((SearchSuggestionDisplayModel) -> Void)?
    var onCustomSuggestionSubmitted: ((String) -> Void)?
    var onMoreSuggestionsSelected: (() -> Void)?

    private let stackView = UIStackView()
    private var suggestions: [SearchSuggestionDisplayModel] = []
    private var canShowMoreSuggestions = false
    private var isAddingCustomSuggestion = false

    private enum Animation {
        static let highlightDuration: TimeInterval = 0.22
        static let highlightedDelay: TimeInterval = 0.45
    }

    private enum Layout {
        static let maxChipWidth: CGFloat = 210
    }

    init(
        suggestions: [SearchSuggestionDisplayModel],
        canShowMoreSuggestions: Bool
    ) {
        super.init(frame: .zero)
        configure(suggestions: suggestions, canShowMoreSuggestions: canShowMoreSuggestions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(
        suggestions: [SearchSuggestionDisplayModel],
        canShowMoreSuggestions: Bool
    ) {
        showsHorizontalScrollIndicator = false
        self.suggestions = suggestions
        self.canShowMoreSuggestions = canShowMoreSuggestions
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

        render(suggestions: suggestions, canShowMoreSuggestions: canShowMoreSuggestions)
    }

    func render(
        suggestions: [SearchSuggestionDisplayModel],
        canShowMoreSuggestions: Bool
    ) {
        self.suggestions = suggestions
        self.canShowMoreSuggestions = canShowMoreSuggestions
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        suggestions.map(makeSuggestionChip).forEach(stackView.addArrangedSubview)
        if canShowMoreSuggestions {
            stackView.addArrangedSubview(makeMoreSuggestionsButton())
        }

        if isAddingCustomSuggestion {
            stackView.addArrangedSubview(makeCustomSuggestionInput())
        } else {
            stackView.addArrangedSubview(makeAddSuggestionButton())
        }
    }

    private func makeSuggestionChip(_ suggestion: SearchSuggestionDisplayModel) -> UIButton {
        let button = UIButton(
            configuration: makeSuggestionConfiguration(title: suggestion.title, isHighlighted: false)
        )
        button.accessibilityIdentifier = "search.suggestionChip"
        button.accessibilityValue = suggestion.title
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.titleLabel?.numberOfLines = 1
        button.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.maxChipWidth).isActive = true
        button.addAction(
            UIAction { [weak self, weak button] _ in
                guard let self else { return }
                if let button {
                    self.highlightSuggestionChip(button, title: suggestion.title)
                }
                self.onSuggestionSelected?(suggestion)
            },
            for: .touchUpInside
        )
        return button
    }

    private func makeMoreSuggestionsButton() -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = L10n.Search.Suggestion.more
        configuration.image = UIImage(systemName: "ellipsis")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        configuration.baseForegroundColor = AppTheme.Color.primary
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 18, bottom: 11, trailing: 18)
        configuration.background.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.55)
        configuration.background.strokeColor = AppTheme.Color.primary.withAlphaComponent(0.55)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 24

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "search.moreSuggestionsButton"
        button.addAction(
            UIAction { [weak self] _ in
                self?.onMoreSuggestionsSelected?()
            },
            for: .touchUpInside
        )
        return button
    }

    private func makeAddSuggestionButton() -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        configuration.baseForegroundColor = AppTheme.Color.primary
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 14, bottom: 11, trailing: 14)
        configuration.background.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.55)
        configuration.background.strokeColor = AppTheme.Color.secondaryAccent.withAlphaComponent(0.65)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 24

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "search.addSuggestionButton"
        button.addAction(
            UIAction { [weak self] _ in
                self?.showCustomSuggestionInput()
            },
            for: .touchUpInside
        )
        return button
    }

    private func makeCustomSuggestionInput() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.72)
        containerView.layer.cornerRadius = 19
        containerView.layer.cornerCurve = .continuous
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.65).cgColor
        containerView.accessibilityIdentifier = "search.customSuggestionInputContainer"

        let textField = UITextField()
        textField.placeholder = L10n.Search.Suggestion.customPlaceholder
        textField.textColor = AppTheme.Color.textPrimary
        textField.tintColor = AppTheme.Color.primary
        textField.font = .systemFont(ofSize: 15, weight: .semibold)
        textField.returnKeyType = .done
        textField.delegate = self
        textField.accessibilityIdentifier = "search.customSuggestionTextField"

        let submitButton = UIButton(type: .system)
        submitButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        submitButton.tintColor = AppTheme.Color.secondaryAccent
        submitButton.accessibilityIdentifier = "search.submitCustomSuggestionButton"
        submitButton.addAction(
            UIAction { [weak self, weak textField] _ in
                self?.submitCustomSuggestion(textField?.text)
            },
            for: .touchUpInside
        )

        let stackView = UIStackView(arrangedSubviews: [textField, submitButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textField.widthAnchor.constraint(equalToConstant: 150),
            submitButton.widthAnchor.constraint(equalToConstant: 24)
        ])

        DispatchQueue.main.async {
            textField.becomeFirstResponder()
        }

        return containerView
    }

    private func makeSuggestionConfiguration(title: String, isHighlighted: Bool) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.titleLineBreakMode = .byTruncatingTail
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

    private func showCustomSuggestionInput() {
        guard !isAddingCustomSuggestion else {
            return
        }

        isAddingCustomSuggestion = true
        UIView.transition(
            with: stackView,
            duration: 0.24,
            options: [.transitionCrossDissolve, .allowUserInteraction]
        ) {
            self.render(
                suggestions: self.suggestions,
                canShowMoreSuggestions: self.canShowMoreSuggestions
            )
        }
    }

    private func submitCustomSuggestion(_ suggestion: String?) {
        let normalizedSuggestion = suggestion?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !normalizedSuggestion.isEmpty else {
            return
        }

        isAddingCustomSuggestion = false
        onCustomSuggestionSubmitted?(normalizedSuggestion)
    }
}

extension SearchSuggestionsView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitCustomSuggestion(textField.text)
        textField.resignFirstResponder()
        return true
    }
}
