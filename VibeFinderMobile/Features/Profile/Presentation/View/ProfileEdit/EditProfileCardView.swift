import UIKit

final class EditProfileCardView: UIView {
    let content = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppTheme.Color.surface
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.border.cgColor
        layer.shadowColor = AppTheme.Color.primary.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 3, height: 3)

        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
