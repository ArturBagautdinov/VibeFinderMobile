import UIKit

final class SearchPromptCardView: UIView {
    let textView = UITextView()
    let submitButton = UIButton(type: .system)

    private let placeholderLabel = UILabel()
    private var submitButtonWidthConstraint: NSLayoutConstraint?
    private var hasQueryText = false
    private var isLoading = false

    private enum Layout {
        static let compactButtonSize: CGFloat = 36
        static let expandedButtonWidth: CGFloat = 110
    }

    var query: String {
        textView.text ?? ""
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.surface
        layer.cornerRadius = 26
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.border.cgColor
        accessibilityIdentifier = "search.promptCard"

        let titleLabel = UILabel()
        titleLabel.text = L10n.Search.Prompt.title
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = AppTheme.Color.primary
        titleLabel.adjustsFontForContentSizeCategory = true

        let iconView = UIImageView(image: UIImage(systemName: "sparkle"))
        iconView.tintColor = AppTheme.Color.primary
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true

        let promptHeader = UIStackView(arrangedSubviews: [iconView, titleLabel])
        promptHeader.axis = .horizontal
        promptHeader.alignment = .center
        promptHeader.spacing = 10

        configureTextView()
        configurePlaceholder()
        configureSubmitButton()

        let inputContainer = UIView()
        inputContainer.addSubview(textView)
        inputContainer.addSubview(placeholderLabel)
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [promptHeader, inputContainer])
        textStack.axis = .vertical
        textStack.spacing = 10
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textStack)
        addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false

        submitButtonWidthConstraint = submitButton.widthAnchor.constraint(equalToConstant: Layout.compactButtonSize)
        submitButtonWidthConstraint?.isActive = true

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            textView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),

            placeholderLabel.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),

            textStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -60),

            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            submitButton.heightAnchor.constraint(equalToConstant: Layout.compactButtonSize),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 172)
        ])
    }

    private func configureTextView() {
        textView.accessibilityIdentifier = "search.promptTextView"
        textView.backgroundColor = .clear
        textView.textColor = AppTheme.Color.textPrimary
        textView.tintColor = AppTheme.Color.primary
        textView.font = .preferredFont(forTextStyle: .title3)
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
    }

    private func configurePlaceholder() {
        placeholderLabel.text = L10n.Search.Prompt.placeholder
        placeholderLabel.font = .preferredFont(forTextStyle: .title3)
        placeholderLabel.textColor = AppTheme.Color.textSecondary
        placeholderLabel.numberOfLines = 0
        placeholderLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.isUserInteractionEnabled = false
    }

    private func configureSubmitButton() {
        applySubmitButtonConfiguration(animated: false)
        submitButton.accessibilityIdentifier = "search.submitButton"
        submitButton.layer.shadowColor = AppTheme.Color.primary.cgColor
        submitButton.layer.shadowOpacity = 0.32
        submitButton.layer.shadowRadius = 18
        submitButton.layer.shadowOffset = CGSize(width: 0, height: 10)
    }

    func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
        submitButton.isEnabled = !isLoading
        applySubmitButtonConfiguration(animated: false)
    }

    func setQuery(_ query: String, animated: Bool) {
        textView.text = query
        updateTextState(animated: animated)
    }

    private func updateTextState(animated: Bool) {
        let hasText = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        placeholderLabel.isHidden = hasText

        guard hasText != hasQueryText else {
            return
        }

        hasQueryText = hasText
        submitButtonWidthConstraint?.constant = hasText
            ? Layout.expandedButtonWidth
            : Layout.compactButtonSize
        applySubmitButtonConfiguration(animated: animated)

        let animations = {
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(
                withDuration: 0.34,
                delay: 0,
                usingSpringWithDamping: 0.84,
                initialSpringVelocity: 0.18,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: animations
            )
        } else {
            animations()
        }
    }

    private func applySubmitButtonConfiguration(animated: Bool) {
        let update = {
            self.submitButton.configuration = self.makeSubmitButtonConfiguration()
        }

        if animated {
            UIView.transition(
                with: submitButton,
                duration: 0.18,
                options: [.transitionCrossDissolve, .allowUserInteraction],
                animations: update
            )
        } else {
            update()
        }
    }

    private func makeSubmitButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.image = isLoading ? nil : UIImage(systemName: "arrow.up")
        if hasQueryText && !isLoading {
            var title = AttributedString(L10n.Search.Prompt.submit)
            title.font = .systemFont(ofSize: 16, weight: .bold)
            configuration.attributedTitle = title
        }
        configuration.imagePlacement = hasQueryText ? .trailing : .leading
        configuration.imagePadding = hasQueryText ? 3 : 0
        configuration.contentInsets = hasQueryText
            ? NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 16)
            : .zero
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        configuration.baseBackgroundColor = isLoading
            ? AppTheme.Color.textSecondary
            : AppTheme.Color.primary
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.showsActivityIndicator = isLoading
        return configuration
    }
}

extension SearchPromptCardView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextState(animated: true)
    }
}
