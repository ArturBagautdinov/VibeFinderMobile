import UIKit

final class EditProfileAvatarEditorView: UIView {
    var onStyleSelected: ((ProfileAvatarStyle) -> Void)?
    var onSymbolSelected: ((String) -> Void)?
    var onColorSelected: ((String) -> Void)?

    private let card = EditProfileCardView()
    private let preview = EditProfilePreviewView()
    private let styleControl = UISegmentedControl(items: [
        L10n.Profile.Edit.symbol, L10n.Profile.Edit.color, L10n.Profile.Edit.none
    ])
    private let symbolTitle = UILabel()
    private let colorTitle = UILabel()
    private let symbolPicker: EditProfileSymbolPickerView
    private let colorPicker: EditProfileColorPickerView

    init(symbols: [String], colors: [String]) {
        symbolPicker = EditProfileSymbolPickerView(symbols: symbols)
        colorPicker = EditProfileColorPickerView(colors: colors)
        super.init(frame: .zero)
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let title = UILabel()
        title.text = L10n.Profile.Edit.avatar
        title.font = .preferredFont(forTextStyle: .headline)
        title.textColor = AppTheme.Color.primary
        title.layer.shadowColor = AppTheme.Color.primary.cgColor
        title.layer.shadowOpacity = 0.25
        title.layer.shadowOffset = CGSize(width: 1, height: 1)
        card.content.addArrangedSubview(title)
        card.content.addArrangedSubview(preview)
        card.content.setCustomSpacing(22, after: preview)

        styleControl.selectedSegmentTintColor = AppTheme.Color.primary
        styleControl.setTitleTextAttributes([.foregroundColor: AppTheme.Color.textPrimary], for: .normal)
        styleControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        styleControl.addTarget(self, action: #selector(styleChanged), for: .valueChanged)
        card.content.addArrangedSubview(styleControl)

        for label in [symbolTitle, colorTitle] {
            label.font = .preferredFont(forTextStyle: .subheadline)
            label.textColor = AppTheme.Color.textSecondary
        }
        symbolTitle.text = L10n.Profile.Edit.chooseSymbol
        colorTitle.text = L10n.Profile.Edit.chooseColor
        card.content.addArrangedSubview(symbolTitle)
        card.content.addArrangedSubview(symbolPicker)
        card.content.addArrangedSubview(colorTitle)
        card.content.addArrangedSubview(colorPicker)
        symbolPicker.onSelect = { [weak self] in self?.onSymbolSelected?($0) }
        colorPicker.onSelect = { [weak self] in self?.onColorSelected?($0) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func render(_ state: EditProfileViewModel.State) {
        preview.render(state)
        let style = state.draft.avatar?.style ?? .none
        styleControl.selectedSegmentIndex = style == .symbol ? 0 : (style == .color ? 1 : 2)
        styleControl.isEnabled = !state.isSaving
        let showsSymbol = style == .symbol
        let showsColor = style != .none
        symbolTitle.isHidden = !showsSymbol
        symbolPicker.isHidden = !showsSymbol
        colorTitle.isHidden = !showsColor
        colorPicker.isHidden = !showsColor
        symbolPicker.render(selected: state.draft.selectedSymbol, isEnabled: !state.isSaving)
        colorPicker.render(selected: state.draft.selectedColor, isEnabled: !state.isSaving)
    }

    @objc private func styleChanged() {
        let style: ProfileAvatarStyle = switch styleControl.selectedSegmentIndex {
        case 0: .symbol
        case 1: .color
        default: .none
        }
        onStyleSelected?(style)
    }
}
