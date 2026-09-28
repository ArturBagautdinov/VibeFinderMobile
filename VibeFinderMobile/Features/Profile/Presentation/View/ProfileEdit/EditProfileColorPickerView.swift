import UIKit

final class EditProfileColorPickerView: UIView {
    var onSelect: ((String) -> Void)?
    private var buttons: [String: UIButton] = [:]

    init(colors: [String]) {
        super.init(frame: .zero)
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 10
        grid.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: topAnchor),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor),
            grid.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        for group in stride(from: 0, to: colors.count, by: 5) {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .equalSpacing
            row.spacing = 8
            for hex in colors[group..<min(group + 5, colors.count)] {
                let button = UIButton(type: .system)
                button.backgroundColor = UIColor(hex: hex)
                button.layer.cornerRadius = 22
                button.layer.cornerCurve = .continuous
                button.layer.borderColor = AppTheme.Color.textPrimary.cgColor
                button.widthAnchor.constraint(equalToConstant: 44).isActive = true
                button.heightAnchor.constraint(equalToConstant: 44).isActive = true
                button.accessibilityLabel = hex
                button.accessibilityIdentifier = "profile.edit.color.\(hex)"
                button.addAction(UIAction { [weak self] _ in self?.onSelect?(hex) }, for: .touchUpInside)
                buttons[hex] = button
                row.addArrangedSubview(button)
            }
            grid.addArrangedSubview(row)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func render(selected: String, isEnabled: Bool) {
        for (hex, button) in buttons {
            let active = hex.caseInsensitiveCompare(selected) == .orderedSame
            button.isEnabled = isEnabled
            button.layer.borderWidth = active ? 3 : 0
            button.accessibilityTraits = active ? [.button, .selected] : .button
        }
    }
}
