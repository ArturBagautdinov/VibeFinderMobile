import UIKit

final class SearchResultsView: UIView {
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(page: SearchPage?) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard let page else {
            isHidden = true
            return
        }

        isHidden = false
        stackView.addArrangedSubview(makeSummaryView(page))
        page.buckets.forEach { bucket in
            stackView.addArrangedSubview(SearchBucketView(bucket: bucket))
        }
    }

    private func configure() {
        isHidden = true
        accessibilityIdentifier = "search.resultsView"

        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func makeSummaryView(_ page: SearchPage) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = page.summary
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 0

        let queryLabel = UILabel()
        queryLabel.text = page.refinedQuery ?? page.originalQuery
        queryLabel.font = .preferredFont(forTextStyle: .subheadline)
        queryLabel.textColor = AppTheme.Color.textSecondary
        queryLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [titleLabel, queryLabel])
        stackView.axis = .vertical
        stackView.spacing = 6

        let container = UIView()
        container.backgroundColor = AppTheme.Color.surface.withAlphaComponent(0.7)
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.layer.borderColor = AppTheme.Color.border.cgColor
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        return container
    }
}

private final class SearchBucketView: UIView {
    private let bucket: SearchBucket

    init(bucket: SearchBucket) {
        self.bucket = bucket
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        let titleLabel = UILabel()
        titleLabel.text = bucket.title
        titleLabel.font = .systemFont(ofSize: 22, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary

        let descriptionLabel = UILabel()
        descriptionLabel.text = bucket.description
        descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = AppTheme.Color.textSecondary
        descriptionLabel.numberOfLines = 0

        let itemViews = bucket.items.map { item in
            SearchRecommendationView(recommendation: item)
        }
        let itemsStack = UIStackView(arrangedSubviews: itemViews)
        itemsStack.axis = .vertical
        itemsStack.spacing = 14

        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, itemsStack])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setCustomSpacing(16, after: descriptionLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private final class SearchRecommendationView: UIView {
    private let recommendation: SearchRecommendation

    init(recommendation: SearchRecommendation) {
        self.recommendation = recommendation
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.surface
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Color.border.cgColor

        let matchLabel = UILabel()
        matchLabel.text = "\(recommendation.overallMatch)%"
        matchLabel.font = .systemFont(ofSize: 18, weight: .black)
        matchLabel.textColor = .white
        matchLabel.textAlignment = .center
        matchLabel.backgroundColor = AppTheme.Color.primary
        matchLabel.layer.cornerRadius = 18
        matchLabel.layer.cornerCurve = .continuous
        matchLabel.clipsToBounds = true
        matchLabel.widthAnchor.constraint(equalToConstant: 54).isActive = true
        matchLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = makeTitle()
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 0

        let descriptionLabel = UILabel()
        descriptionLabel.text = recommendation.shortDescription.isEmpty
            ? recommendation.explanation
            : recommendation.shortDescription
        descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = AppTheme.Color.textSecondary
        descriptionLabel.numberOfLines = 0

        let genresLabel = UILabel()
        genresLabel.text = recommendation.genres.joined(separator: " · ")
        genresLabel.font = .preferredFont(forTextStyle: .caption1)
        genresLabel.textColor = AppTheme.Color.primary
        genresLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, genresLabel])
        textStack.axis = .vertical
        textStack.spacing = 6

        let rowStack = UIStackView(arrangedSubviews: [textStack, matchLabel])
        rowStack.axis = .horizontal
        rowStack.alignment = .top
        rowStack.spacing = 14
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            rowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func makeTitle() -> String {
        guard let releaseYear = recommendation.releaseYear else {
            return recommendation.title
        }
        return "\(recommendation.title) · \(releaseYear)"
    }
}
