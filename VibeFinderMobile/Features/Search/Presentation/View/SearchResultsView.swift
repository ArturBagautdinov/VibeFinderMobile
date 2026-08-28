import UIKit

final class SearchResultsView: UIView {
    let backButton = UIButton(type: .system)
    let collectionView: UICollectionView

    private let page: SearchPage
    private let topBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let topBlurOverlayView = UIView()
    private let topBlurMaskLayer = CAGradientLayer()
    private let stickySummaryView = StickySummaryCapsuleView()

    init(page: SearchPage) {
        self.page = page
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: Self.makeLayout()
        )
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topBlurMaskLayer.frame = topBlurView.bounds
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "search.results.screen"

        configureBackButton()
        stickySummaryView.configure(summary: page.summary)
        configureCollectionView()
        configureTopBlurView()

        addSubview(collectionView)
        addSubview(topBlurView)
        addSubview(backButton)
        addSubview(stickySummaryView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        topBlurView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        stickySummaryView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            topBlurView.topAnchor.constraint(equalTo: topAnchor),
            topBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBlurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBlurView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 110),

            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: stickySummaryView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 42),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),

            stickySummaryView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            stickySummaryView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            stickySummaryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func configureBackButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "chevron.left")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        configuration.baseBackgroundColor = AppTheme.Color.surface
        configuration.baseForegroundColor = AppTheme.Color.primary
        configuration.cornerStyle = .capsule
        backButton.configuration = configuration
        backButton.accessibilityIdentifier = "search.results.backButton"
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = AppTheme.Color.border.cgColor
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 28, right: 0)
        collectionView.accessibilityIdentifier = "search.results.collectionView"
    }

    private func configureTopBlurView() {
        topBlurView.alpha = 0
        topBlurView.isUserInteractionEnabled = false
        topBlurMaskLayer.colors = [
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0.9).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        topBlurMaskLayer.locations = [0, 0.4, 0.6, 0.82, 1]
        topBlurView.layer.mask = topBlurMaskLayer

        topBlurOverlayView.backgroundColor = AppTheme.Color.background.withAlphaComponent(1)
        topBlurOverlayView.translatesAutoresizingMaskIntoConstraints = false

        topBlurView.contentView.addSubview(topBlurOverlayView)

        NSLayoutConstraint.activate([
            topBlurOverlayView.topAnchor.constraint(equalTo: topBlurView.contentView.topAnchor),
            topBlurOverlayView.leadingAnchor.constraint(equalTo: topBlurView.contentView.leadingAnchor),
            topBlurOverlayView.trailingAnchor.constraint(equalTo: topBlurView.contentView.trailingAnchor),
            topBlurOverlayView.bottomAnchor.constraint(equalTo: topBlurView.contentView.bottomAnchor)
        ])
    }

    func updateStickySummaryVisibility(for verticalOffset: CGFloat) {
        let progress = min(max((verticalOffset - 118) / 44, 0), 1)
        topBlurView.alpha = progress * 0.92
        stickySummaryView.alpha = progress
        stickySummaryView.transform = CGAffineTransform(
            translationX: 0,
            y: (1 - progress) * -10
        ).scaledBy(x: 0.96 + progress * 0.04, y: 0.96 + progress * 0.04)
        stickySummaryView.isUserInteractionEnabled = progress > 0.2
    }

    private static func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            let columns = containerWidth < 340 ? 1 : 2

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(350)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(350)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: columns
            )
            group.interItemSpacing = .fixed(14)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 22
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(70)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: SearchResultsDataSource.bucketHeaderKind,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            return section
        }
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        let resultsHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(240)
        )
        let resultsHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: resultsHeaderSize,
            elementKind: SearchResultsDataSource.resultsHeaderKind,
            alignment: .top
        )
        configuration.boundarySupplementaryItems = [resultsHeader]
        layout.configuration = configuration
        return layout
    }
}
