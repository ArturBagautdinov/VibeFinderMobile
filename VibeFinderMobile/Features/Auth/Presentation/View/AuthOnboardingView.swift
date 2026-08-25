import UIKit

final class AuthOnboardingView: UIView {
    let startButton = PrimaryButton(type: .system)
    let signInButton = UIButton(type: .system)

    private let promptCloudView = FloatingPromptCloudView(prompts: AuthPromptFactory.makePrompts())

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startFloatingPrompts() {
        promptCloudView.startFloating()
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "auth.onboarding.screen"

        let titleLabel = UILabel()
        titleLabel.attributedText = makeTitle()
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityIdentifier = "auth.onboarding.titleLabel"

        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.Auth.Onboarding.subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .title3)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true

        startButton.setTitle(L10n.Auth.Onboarding.start, for: .normal)
        startButton.accessibilityIdentifier = "auth.onboarding.startButton"

        var signInConfiguration = UIButton.Configuration.plain()
        signInConfiguration.title = L10n.Auth.Onboarding.signIn
        signInConfiguration.baseForegroundColor = AppTheme.Color.textPrimary
        signInConfiguration.background.strokeColor = AppTheme.Color.border
        signInConfiguration.background.strokeWidth = 1
        signInConfiguration.background.cornerRadius = 26
        signInButton.configuration = signInConfiguration
        signInButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        signInButton.accessibilityIdentifier = "auth.onboarding.signInButton"
        signInButton.heightAnchor.constraint(equalToConstant: 54).isActive = true

        let contentStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            startButton,
            signInButton
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.setCustomSpacing(28, after: subtitleLabel)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        promptCloudView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(promptCloudView)
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            promptCloudView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 42),
            promptCloudView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            promptCloudView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            promptCloudView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.42),

            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            contentStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -36)
        ])
    }

    private func makeTitle() -> NSAttributedString {
        let title = L10n.Auth.Onboarding.title
        let highlight = L10n.Auth.Onboarding.titleHighlight
        let attributedTitle = NSMutableAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 42, weight: .black),
                .foregroundColor: AppTheme.Color.textPrimary
            ]
        )

        let range = (title as NSString).range(of: highlight)
        if range.location != NSNotFound {
            attributedTitle.addAttributes(
                [.foregroundColor: AppTheme.Color.secondaryAccent],
                range: range
            )
        }

        return attributedTitle
    }
}
