import UIKit

final class MediaDetailsChipRowView: UIView {
    init(title: String?, items: [String]) {
        super.init(frame: .zero)
        configure(title: title, items: items)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(title: String?, items: [String]) {
        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.spacing = 10
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)

        if let title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
            titleLabel.textColor = AppTheme.Color.textPrimary
            titleLabel.adjustsFontForContentSizeCategory = true
            outerStack.addArrangedSubview(titleLabel)
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
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = AppTheme.Color.textPrimary
            label.backgroundColor = AppTheme.Color.surface
            label.layer.borderWidth = 1
            label.layer.borderColor = AppTheme.Color.border.cgColor
            label.layer.cornerRadius = 15
            label.layer.cornerCurve = .continuous
            label.layer.masksToBounds = true
            label.contentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            chips.addArrangedSubview(label)
        }
        outerStack.addArrangedSubview(scrollView)

        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            chips.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            chips.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            chips.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            chips.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            chips.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
}
