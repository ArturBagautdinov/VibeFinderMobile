import UIKit

final class EditProfileView: UIView {
    var onBack: (() -> Void)?
    var onSave: (() -> Void)?
    var onNamesChanged: ((String, String) -> Void)?
    var onStyleSelected: ((ProfileAvatarStyle) -> Void)?
    var onSymbolSelected: ((String) -> Void)?
    var onColorSelected: ((String) -> Void)?

    private let namesView = EditProfileNamesView()
    private let avatarView: EditProfileAvatarEditorView
    private let statusView = SearchStatusView()
    private let saveButton = PrimaryButton()

    init(symbols: [String], colors: [String]) {
        avatarView = EditProfileAvatarEditorView(symbols: symbols, colors: colors)
        super.init(frame: .zero)
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "profile.edit.screen"

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = AppTheme.Color.textPrimary
        backButton.accessibilityLabel = L10n.Common.cancel
        backButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        backButton.addAction(UIAction { [weak self] _ in self?.onBack?() }, for: .touchUpInside)
        let title = UILabel()
        title.text = L10n.Profile.Edit.title
        title.font = .preferredFont(forTextStyle: .headline)
        title.textColor = AppTheme.Color.textPrimary
        title.textAlignment = .center
        let spacer = UIView()
        spacer.widthAnchor.constraint(equalToConstant: 44).isActive = true
        let header = UIStackView(arrangedSubviews: [backButton, title, spacer])
        header.axis = .horizontal
        header.alignment = .center
        header.translatesAutoresizingMaskIntoConstraints = false
        addSubview(header)

        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .interactive
        scroll.translatesAutoresizingMaskIntoConstraints = false
        let content = UIStackView(arrangedSubviews: [namesView, avatarView, statusView])
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        addSubview(scroll)

        saveButton.setTitle(L10n.Profile.Edit.save, for: .normal)
        saveButton.accessibilityIdentifier = "profile.edit.save"
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addAction(UIAction { [weak self] _ in self?.onSave?() }, for: .touchUpInside)
        addSubview(saveButton)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            header.heightAnchor.constraint(equalToConstant: 44),

            scroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 4),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),

            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -12)
        ])

        namesView.onChange = { [weak self] first, last in self?.onNamesChanged?(first, last) }
        avatarView.onStyleSelected = { [weak self] in self?.onStyleSelected?($0) }
        avatarView.onSymbolSelected = { [weak self] in self?.onSymbolSelected?($0) }
        avatarView.onColorSelected = { [weak self] in self?.onColorSelected?($0) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func render(_ state: EditProfileViewModel.State) {
        namesView.render(state.draft, isSaving: state.isSaving)
        avatarView.render(state)
        statusView.setMessage(state.errorMessage)
        saveButton.setLoading(state.isSaving)
        saveButton.isEnabled = state.canSave
    }
}
