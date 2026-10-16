import UIKit

final class MediaDetailsChipRowView: UIView {
    init(title: String?, symbol: String? = nil, items: [String]) {
        super.init(frame: .zero)
        configure(title: title, symbol: symbol, items: items)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(title: String?, symbol: String?, items: [String]) {
        let isTagGroup = title != nil
        if isTagGroup {
            backgroundColor = AppTheme.Color.surface
            layer.cornerRadius = 20
            layer.cornerCurve = .continuous
            layer.borderWidth = 1
            layer.borderColor = AppTheme.Color.border.cgColor
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.06
            layer.shadowRadius = 12
            layer.shadowOffset = CGSize(width: 0, height: 5)
        }

        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.spacing = 14
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)

        if let title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(
                for: .systemFont(ofSize: 17, weight: .semibold)
            )
            titleLabel.textColor = AppTheme.Color.textPrimary
            titleLabel.adjustsFontForContentSizeCategory = true

            let header = UIStackView()
            header.axis = .horizontal
            header.alignment = .center
            header.spacing = 11

            if let symbol {
                let iconBackground = UIView()
                iconBackground.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.12)
                iconBackground.layer.cornerRadius = 11
                iconBackground.layer.cornerCurve = .continuous
                iconBackground.translatesAutoresizingMaskIntoConstraints = false

                let iconView = UIImageView(image: UIImage(systemName: symbol))
                iconView.tintColor = AppTheme.Color.primary
                iconView.contentMode = .scaleAspectFit
                iconView.isAccessibilityElement = false
                iconView.translatesAutoresizingMaskIntoConstraints = false
                iconBackground.addSubview(iconView)

                NSLayoutConstraint.activate([
                    iconBackground.widthAnchor.constraint(equalToConstant: 34),
                    iconBackground.heightAnchor.constraint(equalTo: iconBackground.widthAnchor),
                    iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
                    iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: 17),
                    iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor)
                ])
                header.addArrangedSubview(iconBackground)
            }
            header.addArrangedSubview(titleLabel)
            outerStack.addArrangedSubview(header)
        }

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        let chips = UIStackView()
        chips.axis = .horizontal
        chips.spacing = 8
        chips.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(chips)

        for item in items {
            let label = PaddedLabel()
            label.text = item
            label.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(
                for: .systemFont(ofSize: 13, weight: .medium)
            )
            label.adjustsFontForContentSizeCategory = true
            label.textColor = AppTheme.Color.textPrimary
            label.backgroundColor = isTagGroup
                ? AppTheme.Color.primary.withAlphaComponent(0.08)
                : AppTheme.Color.surface
            label.layer.borderWidth = 1
            label.layer.borderColor = isTagGroup
                ? AppTheme.Color.primary.withAlphaComponent(0.22).cgColor
                : AppTheme.Color.border.cgColor
            label.layer.cornerRadius = 15
            label.layer.cornerCurve = .continuous
            label.layer.masksToBounds = true
            label.contentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            chips.addArrangedSubview(label)
        }
        outerStack.addArrangedSubview(scrollView)

        let inset: CGFloat = isTagGroup ? 16 : 0
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            chips.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            chips.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            chips.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            chips.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            chips.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
}
