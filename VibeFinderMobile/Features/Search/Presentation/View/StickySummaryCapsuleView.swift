
import Foundation
import UIKit

final class StickySummaryCapsuleView: UIView {
    private let summaryLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(summary: String) {
        summaryLabel.text = summary
    }

    private func configure() {
        alpha = 0
        isUserInteractionEnabled = false
        backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.96)
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.35).cgColor
        layer.shadowColor = AppTheme.Color.primary.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 8)
        accessibilityIdentifier = "search.results.stickySummary"

        summaryLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        summaryLabel.textColor = AppTheme.Color.textPrimary
        summaryLabel.numberOfLines = 4
        summaryLabel.lineBreakMode = .byTruncatingTail
        summaryLabel.adjustsFontForContentSizeCategory = true
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(summaryLabel)

        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            summaryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
