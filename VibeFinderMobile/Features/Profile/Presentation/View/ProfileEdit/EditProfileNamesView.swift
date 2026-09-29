import UIKit

final class EditProfileNamesView: UIView, UITextFieldDelegate {
    var onChange: ((String, String) -> Void)?

    private let card = EditProfileCardView()
    private let firstNameField = AuthTextField(placeholder: L10n.Auth.Register.firstName, textContentType: .givenName)
    private let lastNameField = AuthTextField(placeholder: L10n.Auth.Register.lastName, textContentType: .familyName)

    override init(frame: CGRect) {
        super.init(frame: frame)
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let title = UILabel()
        title.text = L10n.Profile.Edit.personal
        title.font = .preferredFont(forTextStyle: .headline)
        title.textColor = AppTheme.Color.primary
        title.layer.shadowColor = AppTheme.Color.primary.cgColor
        title.layer.shadowOpacity = 0.25
        title.layer.shadowOffset = CGSize(width: 1, height: 1)
        card.content.addArrangedSubview(title)

        [firstNameField, lastNameField].forEach { field in
            field.autocapitalizationType = .words
            field.autocorrectionType = .no
            field.addTarget(self, action: #selector(namesDidChange), for: .editingChanged)
            card.content.addArrangedSubview(field)
        }
        firstNameField.returnKeyType = .next
        lastNameField.returnKeyType = .done
        firstNameField.delegate = self
        lastNameField.delegate = self
        firstNameField.accessibilityIdentifier = "profile.edit.firstName"
        lastNameField.accessibilityIdentifier = "profile.edit.lastName"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func render(_ draft: EditProfileDraft, isSaving: Bool) {
        if firstNameField.text != draft.firstName { firstNameField.text = draft.firstName }
        if lastNameField.text != draft.lastName { lastNameField.text = draft.lastName }
        firstNameField.isEnabled = !isSaving
        lastNameField.isEnabled = !isSaving
    }

    @objc private func namesDidChange() {
        onChange?(firstNameField.text ?? "", lastNameField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === firstNameField { lastNameField.becomeFirstResponder() }
        else { lastNameField.resignFirstResponder() }
        return true
    }
}
