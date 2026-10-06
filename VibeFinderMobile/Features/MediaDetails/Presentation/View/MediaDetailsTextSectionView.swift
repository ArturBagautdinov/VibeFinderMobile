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
        let accentColor: UIColor
        let symbolName: String?
        switch style {
        case .standard:
            accentColor = AppTheme.Color.textPrimary
            symbolName = nil
            backgroundColor = AppTheme.Color.surface
        case .highlight:
            accentColor = AppTheme.Color.primary
            symbolName = "sparkles"
            backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.10)
        case .warning:
            accentColor = AppTheme.Color.secondaryAccent
            symbolName = "exclamationmark.triangle.fill"
            backgroundColor = AppTheme.Color.secondaryAccent.withAlphaComponent(0.10)
        }
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = style == .standard
            ? AppTheme.Color.border.cgColor
            : accentColor.withAlphaComponent(0.28).cgColor

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = accentColor
        titleLabel.adjustsFontForContentSizeCategory = true

        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 9
        if let symbolName {
            let iconView = UIImageView(image: UIImage(systemName: symbolName))
            iconView.tintColor = accentColor
            iconView.contentMode = .scaleAspectFit
            iconView.setContentHuggingPriority(.required, for: .horizontal)
            iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true
            titleRow.addArrangedSubview(iconView)
        }
        titleRow.addArrangedSubview(titleLabel)

        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        bodyLabel.textColor = AppTheme.Color.textPrimary
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontForContentSizeCategory = true

        let stack = UIStackView(arrangedSubviews: [titleRow, bodyLabel])
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
