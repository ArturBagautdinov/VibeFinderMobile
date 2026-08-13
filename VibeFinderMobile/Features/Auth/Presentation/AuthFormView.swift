import UIKit

final class AuthFormView: UIView {
    enum Mode {
        case login
        case register
    }

    let identifierField = AuthTextField(
        placeholder: L10n.Auth.Login.identifier,
        textContentType: .username
    )
    let emailField = AuthTextField(
        placeholder: L10n.Auth.Register.email,
        textContentType: .emailAddress,
        keyboardType: .emailAddress
    )
    let usernameField = AuthTextField(
        placeholder: L10n.Auth.Register.username,
        textContentType: .username
    )
    let firstNameField = AuthTextField(
        placeholder: L10n.Auth.Register.firstName,
        textContentType: .givenName
    )
    let lastNameField = AuthTextField(
        placeholder: L10n.Auth.Register.lastName,
        textContentType: .familyName
    )
    let passwordField = AuthTextField(
        placeholder: L10n.Auth.Common.password,
        textContentType: .password,
        isSecureTextEntry: true
    )
    let confirmPasswordField = AuthTextField(
        placeholder: L10n.Auth.Register.confirmPassword,
        textContentType: .newPassword,
        isSecureTextEntry: true
    )
    let submitButton = PrimaryButton(type: .system)
    let switchButton = UIButton(type: .system)

    private let errorLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let scrollView = UIScrollView()

    init(mode: Mode) {
        super.init(frame: .zero)
        configure(mode: mode)
        subscribeToKeyboardNotifications()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setLoading(_ isLoading: Bool) {
        submitButton.setLoading(isLoading)
    }

    func setError(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil
    }

    private func configure(mode: Mode) {
        backgroundColor = AppTheme.Color.background

        let logoImageView = AppTheme.makeLogoImageView(height: mode == .login ? 82 : 80)

        titleLabel.text = mode == .login ? L10n.Auth.Login.headline : L10n.Auth.Register.headline
        titleLabel.font = mode == .login ? .preferredFont(forTextStyle: .largeTitle) : .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        subtitleLabel.text = mode == .login ? L10n.Auth.Login.subtitle : L10n.Auth.Register.subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true

        submitButton.setTitle(mode == .login ? L10n.Auth.Login.submit : L10n.Auth.Register.submit, for: .normal)

        switchButton.setTitle(mode == .login ? L10n.Auth.Login.createAccount : L10n.Auth.Register.haveAccount, for: .normal)
        switchButton.tintColor = AppTheme.Color.accent

        errorLabel.font = .preferredFont(forTextStyle: .footnote)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        let fields = mode == .login
            ? [identifierField, passwordField]
            : [emailField, usernameField, firstNameField, lastNameField, passwordField, confirmPasswordField]

        let stackView = UIStackView(arrangedSubviews: [
            logoImageView,
            titleLabel,
            subtitleLabel
        ] + fields + [
            errorLabel,
            submitButton,
            switchButton
        ])
        stackView.axis = .vertical
        stackView.spacing = mode == .login ? 14 : 12
        stackView.setCustomSpacing(mode == .login ? 22 : 18, after: logoImageView)
        stackView.setCustomSpacing(mode == .login ? 28 : 24, after: subtitleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: mode == .login ? 40 : 24),
            stackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -24
            )
        ])
    }

    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else {
            return
        }

        let keyboardFrameInView = convert(keyboardFrame, from: nil)
        let overlap = max(0, bounds.maxY - keyboardFrameInView.minY)
        updateScrollInsets(bottom: overlap, duration: duration)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        updateScrollInsets(bottom: 0, duration: duration)
    }

    private func updateScrollInsets(bottom: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = bottom
            self.scrollView.verticalScrollIndicatorInsets.bottom = bottom
        }
    }
}
