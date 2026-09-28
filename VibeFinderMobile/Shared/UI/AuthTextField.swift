import UIKit

final class AuthTextField: UITextField {
    init(
        placeholder: String,
        textContentType: UITextContentType? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecureTextEntry: Bool = false
    ) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.textContentType = textContentType
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureTextEntry
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        autocapitalizationType = .none
        autocorrectionType = .no
        borderStyle = .none
        backgroundColor = AppTheme.Color.surface
        textColor = AppTheme.Color.textPrimary
        tintColor = AppTheme.Color.accent
        font = .preferredFont(forTextStyle: .title3)
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: AppTheme.Color.textSecondary.withAlphaComponent(0.8)]
        )
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 1
        heightAnchor.constraint(equalToConstant: 52).isActive = true
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 1))
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 1))
        rightViewMode = .always
    }
}
