import UIKit

final class SearchResultsHeroHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with displayModel: SearchResultsHeaderDisplayModel) {
        titleLabel.text = displayModel.title
        summaryLabel.text = displayModel.summary
    }

    private func configure() {
        titleLabel.font = .systemFont(ofSize: 40, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        summaryLabel.font = .systemFont(ofSize: 20, weight: .medium)
        summaryLabel.textColor = AppTheme.Color.textSecondary
        summaryLabel.numberOfLines = 0
        summaryLabel.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView(arrangedSubviews: [titleLabel, summaryLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 80),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
