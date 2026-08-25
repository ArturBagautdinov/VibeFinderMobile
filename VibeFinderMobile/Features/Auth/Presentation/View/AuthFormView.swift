import UIKit

final class AuthFormView: UIView, UITextFieldDelegate {
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
    let backButton = UIButton(type: .system)

    private let errorLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let brandTitleView = FloatingBrandTitleView()
    private var orderedFields: [UITextField] = []

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

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else {
            return
        }
        brandTitleView.startFloating()
    }

    func setLoading(_ isLoading: Bool) {
        submitButton.setLoading(isLoading)
    }

    func setError(_ message: String?) {
        errorLabel.text = message
        errorLabel.accessibilityLabel = message
        errorLabel.isAccessibilityElement = message != nil
        errorLabel.isHidden = message == nil
    }

    private func configure(mode: Mode) {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = mode == .login ? "auth.login.screen" : "auth.register.screen"

        configureBackButton(mode: mode)

        titleLabel.text = mode == .login ? L10n.Auth.Login.headline : L10n.Auth.Register.headline
        titleLabel.accessibilityIdentifier = mode == .login ? "auth.login.titleLabel" : "auth.register.titleLabel"
        titleLabel.font = .systemFont(ofSize: mode == .login ? 42 : 38, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        subtitleLabel.text = mode == .login ? L10n.Auth.Login.subtitle : L10n.Auth.Register.subtitle
        subtitleLabel.accessibilityIdentifier = mode == .login ? "auth.login.subtitleLabel" : "auth.register.subtitleLabel"
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true

        submitButton.setTitle(mode == .login ? L10n.Auth.Login.submit : L10n.Auth.Register.submit, for: .normal)
        submitButton.accessibilityIdentifier = mode == .login ? "auth.login.submitButton" : "auth.register.submitButton"

        switchButton.setTitle(mode == .login ? L10n.Auth.Login.createAccount : L10n.Auth.Register.haveAccount, for: .normal)
        switchButton.accessibilityIdentifier = mode == .login ? "auth.login.switchToRegisterButton" : "auth.register.switchToLoginButton"
        switchButton.tintColor = AppTheme.Color.accent
        switchButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)

        errorLabel.font = .preferredFont(forTextStyle: .footnote)
        errorLabel.accessibilityIdentifier = "auth.errorLabel"
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        let fields = mode == .login
            ? [identifierField, passwordField]
            : [emailField, usernameField, firstNameField, lastNameField, passwordField, confirmPasswordField]
        orderedFields = fields
        configureTextFields(fields)
        configureAccessibilityIdentifiers(mode: mode)

        let fieldSections = mode == .login
            ? [
                makeFieldSection(title: L10n.Auth.Login.identifierLabel, field: identifierField),
                makeFieldSection(title: L10n.Auth.Common.password, field: passwordField)
            ]
            : [
                makeFieldSection(title: L10n.Auth.Register.email, field: emailField),
                makeFieldSection(title: L10n.Auth.Register.username, field: usernameField),
                makeFieldSection(title: L10n.Auth.Register.firstName, field: firstNameField),
                makeFieldSection(title: L10n.Auth.Register.lastName, field: lastNameField),
                makeFieldSection(title: L10n.Auth.Common.password, field: passwordField),
                makeFieldSection(title: L10n.Auth.Register.confirmPassword, field: confirmPasswordField)
            ]

        let stackView = UIStackView(arrangedSubviews: [
            makeBackButtonRow(),
            brandTitleView,
            titleLabel,
            subtitleLabel
        ] + fieldSections + [
            errorLabel,
            submitButton,
            switchButton
        ])
        stackView.axis = .vertical
        stackView.spacing = mode == .login ? 16 : 14
        stackView.setCustomSpacing(18, after: backButton)
        stackView.setCustomSpacing(mode == .login ? 32 : 24, after: brandTitleView)
        stackView.setCustomSpacing(10, after: titleLabel)
        stackView.setCustomSpacing(mode == .login ? 34 : 26, after: subtitleLabel)
        stackView.setCustomSpacing(24, after: errorLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        brandTitleView.heightAnchor.constraint(equalToConstant: mode == .login ? 96 : 82).isActive = true

        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.accessibilityIdentifier = mode == .login ? "auth.login.scrollView" : "auth.register.scrollView"
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        addSubview(scrollView)
        addKeyboardDismissTapGesture()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -24
            )
        ])
    }

    private func configureBackButton(mode: Mode) {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "questionmark")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: 15,
            weight: .bold
        )
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        configuration.baseBackgroundColor = AppTheme.Color.surface
        configuration.baseForegroundColor = AppTheme.Color.primary
        backButton.configuration = configuration
        backButton.accessibilityIdentifier = mode == .login ? "auth.login.backButton" : "auth.register.backButton"
        backButton.accessibilityLabel = L10n.Common.back
        backButton.layer.cornerRadius = 22
        backButton.layer.cornerCurve = .continuous
        backButton.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.35).cgColor
        backButton.layer.borderWidth = 1
        backButton.layer.shadowColor = AppTheme.Color.primary.cgColor
        backButton.layer.shadowOpacity = 0.18
        backButton.layer.shadowRadius = 10
        backButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        backButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func makeBackButtonRow() -> UIView {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: rowView.topAnchor),
            backButton.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            backButton.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
            rowView.heightAnchor.constraint(equalToConstant: 44)
        ])

        return rowView
    }

    private func makeFieldSection(title: String, field: UITextField) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = AppTheme.Color.textSecondary
        label.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView(arrangedSubviews: [label, field])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }

    private func configureTextFields(_ fields: [UITextField]) {
        fields.enumerated().forEach { index, field in
            field.delegate = self
            field.returnKeyType = index == fields.indices.last ? .done : .next
        }
    }

    private func configureAccessibilityIdentifiers(mode: Mode) {
        passwordField.accessibilityIdentifier = mode == .login
            ? "auth.login.passwordTextField"
            : "auth.register.passwordTextField"
        identifierField.accessibilityIdentifier = "auth.login.identifierTextField"
        emailField.accessibilityIdentifier = "auth.register.emailTextField"
        usernameField.accessibilityIdentifier = "auth.register.usernameTextField"
        firstNameField.accessibilityIdentifier = "auth.register.firstNameTextField"
        lastNameField.accessibilityIdentifier = "auth.register.lastNameTextField"
        confirmPasswordField.accessibilityIdentifier = "auth.register.confirmPasswordTextField"
    }

    private func addKeyboardDismissTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = orderedFields.firstIndex(of: textField) else {
            dismissKeyboard()
            return true
        }

        let nextIndex = orderedFields.index(after: index)
        if orderedFields.indices.contains(nextIndex) {
            orderedFields[nextIndex].becomeFirstResponder()
        } else {
            dismissKeyboard()
        }

        return true
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

    @objc private func dismissKeyboard() {
        endEditing(true)
    }
}
