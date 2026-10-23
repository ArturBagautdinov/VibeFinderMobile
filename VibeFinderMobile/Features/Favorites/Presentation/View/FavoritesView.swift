import UIKit

final class FavoritesView: UIView {
    var onFavoriteSelected: ((Int) -> Void)?
    var onRefreshRequested: (() -> Void)?

    private let imageLoader: RemoteImageLoading
    private let errorView = FavoritesErrorView()
    private let emptyView = FavoritesEmptyView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    private lazy var dataSource = makeDataSource()
    private var displayModels: [Int: FavoriteItemDisplayModel] = [:]

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Int>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>

    private nonisolated enum Section: Hashable {
        case main
    }

    init(imageLoader: RemoteImageLoading) {
        self.imageLoader = imageLoader
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(_ state: FavoritesViewModel.State) {
        let items: [FavoriteItem]
        switch state.content {
        case .notLoaded, .empty:
            items = []
        case let .items(loadedItems):
            items = loadedItems
        }

        applySnapshot(items.map { FavoriteItemDisplayModel(item: $0) })
        emptyView.isHidden = !isEmpty(state.content) || state.errorMessage != nil
        errorView.setMessage(state.errorMessage, isLoading: state.isLoading)

        let isInitialLoading = state.isLoading && isNotLoaded(state.content)
        loadingIndicator.isHidden = !isInitialLoading
        isInitialLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        if !state.isLoading { refreshControl.endRefreshing() }
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "favorites.screen"
        emptyView.isUserInteractionEnabled = false

        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        collectionView.accessibilityIdentifier = "favorites.collectionView"
        refreshControl.tintColor = AppTheme.Color.primary
        refreshControl.accessibilityLabel = L10n.Favorites.refresh
        refreshControl.addAction(UIAction { [weak self] _ in
            self?.onRefreshRequested?()
        }, for: .valueChanged)

        errorView.onRetrySelected = { [weak self] in
            self?.onRefreshRequested?()
        }
        loadingIndicator.color = AppTheme.Color.primary
        loadingIndicator.hidesWhenStopped = true

        let header = makeHeader()
        let content = UIStackView(arrangedSubviews: [header, errorView, collectionView])
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false

        [content, emptyView, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 18),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            emptyView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -24),

            loadingIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -32)
        ])
        render(FavoritesViewModel.State(content: .notLoaded, isLoading: false, errorMessage: nil))
    }

    private func makeHeader() -> UIView {
        let iconContainer = UIView()
        iconContainer.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.18)
        iconContainer.layer.cornerRadius = 18
        iconContainer.layer.cornerCurve = .continuous
        iconContainer.layer.borderWidth = 1
        iconContainer.layer.borderColor = AppTheme.Color.primary.withAlphaComponent(0.32).cgColor

        let iconView = UIImageView(image: UIImage(systemName: "heart.fill"))
        iconView.tintColor = AppTheme.Color.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = L10n.Favorites.title
        titleLabel.font = .systemFont(ofSize: 28, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true

        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.Favorites.subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = AppTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = 3

        let header = UIStackView(arrangedSubviews: [iconContainer, labels])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 14

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 56),
            iconContainer.heightAnchor.constraint(equalTo: iconContainer.widthAnchor),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor)
        ])
        return header
    }

    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(162)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 32, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func makeDataSource() -> DataSource {
        let registration = UICollectionView.CellRegistration<FavoritesItemCell, Int> {
            [weak self] cell, _, mediaId in
            guard let self, let model = self.displayModels[mediaId] else { return }
            cell.configure(with: model, imageLoader: self.imageLoader)
        }
        return DataSource(collectionView: collectionView) { collectionView, indexPath, mediaId in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: mediaId)
        }
    }

    private func applySnapshot(_ models: [FavoriteItemDisplayModel]) {
        let previousModels = displayModels
        displayModels = Dictionary(uniqueKeysWithValues: models.map { ($0.mediaId, $0) })
        let ids = models.map(\.mediaId)
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(ids)
        let changedIDs = ids.filter { id in
            previousModels[id] != nil && previousModels[id] != displayModels[id]
        }
        snapshot.reconfigureItems(changedIDs)
        dataSource.apply(snapshot, animatingDifferences: dataSource.snapshot().itemIdentifiers != ids)
    }

    private func isEmpty(_ content: FavoritesViewModel.State.Content) -> Bool {
        if case .empty = content { return true }
        return false
    }

    private func isNotLoaded(_ content: FavoritesViewModel.State.Content) -> Bool {
        if case .notLoaded = content { return true }
        return false
    }
}

extension FavoritesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let mediaId = dataSource.itemIdentifier(for: indexPath) else { return }
        onFavoriteSelected?(mediaId)
    }
}
