import UIKit

final class EditProfileSymbolPickerView: UIView {
    var onSelect: ((String) -> Void)?
    private var buttons: [String: UIButton] = [:]

    init(symbols: [String]) {
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

        for group in stride(from: 0, to: symbols.count, by: 4) {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 10
            for symbol in symbols[group..<min(group + 4, symbols.count)] {
                let button = UIButton(type: .system)
                button.setImage(UIImage(systemName: symbol), for: .normal)
                button.tintColor = AppTheme.Color.textPrimary
                button.backgroundColor = AppTheme.Color.background
                button.layer.cornerRadius = 14
                button.layer.cornerCurve = .continuous
                button.layer.borderWidth = 1
                button.layer.borderColor = AppTheme.Color.border.cgColor
                button.heightAnchor.constraint(equalToConstant: 54).isActive = true
                button.accessibilityLabel = symbol
                button.accessibilityIdentifier = "profile.edit.symbol.\(symbol)"
                button.addAction(UIAction { [weak self] _ in self?.onSelect?(symbol) }, for: .touchUpInside)
                buttons[symbol] = button
                row.addArrangedSubview(button)
            }
            for _ in row.arrangedSubviews.count..<4 {
                let spacer = UIView()
                row.addArrangedSubview(spacer)
            }
            grid.addArrangedSubview(row)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func render(selected: String, isEnabled: Bool) {
        for (symbol, button) in buttons {
            let active = symbol == selected
            button.isEnabled = isEnabled
            button.tintColor = active ? AppTheme.Color.primary : AppTheme.Color.textPrimary
            button.layer.borderColor = (active ? AppTheme.Color.primary : AppTheme.Color.border).cgColor
            button.layer.borderWidth = active ? 2 : 1
            button.accessibilityTraits = active ? [.button, .selected] : .button
        }
    }
}
