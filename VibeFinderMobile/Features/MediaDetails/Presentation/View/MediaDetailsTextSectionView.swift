import UIKit

final class MediaDetailsTextSectionView: UIView {
    enum Style {
        case standard
        case highlight
        case warning
    }

    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    init(title: String, body: String, style: Style = .standard) {
        super.init(frame: .zero)
        configure(title: title, body: body, style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(title: String, body: String, style: Style) {
        backgroundColor = style == .standard
            ? AppTheme.Color.surface
            : AppTheme.Color.primary.withAlphaComponent(style == .warning ? 0.10 : 0.16)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = style == .standard
            ? AppTheme.Color.border.cgColor
            : AppTheme.Color.primary.withAlphaComponent(0.36).cgColor

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = style == .standard
            ? AppTheme.Color.textPrimary
            : AppTheme.Color.secondaryAccent
        titleLabel.adjustsFontForContentSizeCategory = true

        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        bodyLabel.textColor = AppTheme.Color.textPrimary
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontForContentSizeCategory = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
    }
}
