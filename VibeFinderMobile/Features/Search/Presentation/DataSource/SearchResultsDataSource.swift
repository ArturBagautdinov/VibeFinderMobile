import UIKit

nonisolated struct SearchResultsSectionIdentifier: Hashable, Sendable {
    let id: String
    let title: String
    let description: String

    nonisolated static func == (
        lhs: SearchResultsSectionIdentifier,
        rhs: SearchResultsSectionIdentifier
    ) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

nonisolated struct SearchResultItemIdentifier: Hashable, Sendable {
    let id: String
    let displayModel: SearchResultCellDisplayModel

    nonisolated static func == (
        lhs: SearchResultItemIdentifier,
        rhs: SearchResultItemIdentifier
    ) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class SearchResultsDataSource {
    static let resultsHeaderKind = "search.results.header"
    static let bucketHeaderKind = "search.results.bucketHeader"

    private typealias DataSource = UICollectionViewDiffableDataSource<
        SearchResultsSectionIdentifier,
        SearchResultItemIdentifier
    >
    private typealias Snapshot = NSDiffableDataSourceSnapshot<
        SearchResultsSectionIdentifier,
        SearchResultItemIdentifier
    >

    private let header: SearchResultsHeaderDisplayModel
    private let imageLoader: RemoteImageLoading
    private var dataSource: DataSource?

    init(
        collectionView: UICollectionView,
        header: SearchResultsHeaderDisplayModel,
        imageLoader: RemoteImageLoading
    ) {
        self.header = header
        self.imageLoader = imageLoader
        configureDataSource(for: collectionView)
    }

    func apply(
        sections: [SearchResultsSectionDisplayModel],
        completion: @escaping () -> Void
    ) {
        guard let dataSource else {
            completion()
            return
        }
        dataSource.apply(
            makeSnapshot(from: sections),
            animatingDifferences: true,
            completion: completion
        )
    }

    func mediaId(at indexPath: IndexPath) -> Int? {
        dataSource?.itemIdentifier(for: indexPath)?.displayModel.mediaId
    }

    private func configureDataSource(for collectionView: UICollectionView) {
        let cellRegistration = makeCellRegistration()
        let resultsHeaderRegistration = makeResultsHeaderRegistration()
        let headerRegistration = makeHeaderRegistration()

        dataSource = DataSource(collectionView: collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }

        dataSource?.supplementaryViewProvider = {
            collectionView, elementKind, indexPath -> UICollectionReusableView? in
            if elementKind == Self.resultsHeaderKind {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: resultsHeaderRegistration,
                    for: indexPath
                )
            }

            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }

    private func makeCellRegistration() -> UICollectionView.CellRegistration<
        SearchResultCell,
        SearchResultItemIdentifier
    > {
        UICollectionView.CellRegistration<SearchResultCell, SearchResultItemIdentifier> { [imageLoader] cell, _, item in
            cell.configure(
                with: item.displayModel,
                imageLoader: imageLoader
            )
        }
    }

    private func makeResultsHeaderRegistration() -> UICollectionView.SupplementaryRegistration<SearchResultsHeroHeaderView> {
        UICollectionView.SupplementaryRegistration<SearchResultsHeroHeaderView>(
            elementKind: Self.resultsHeaderKind
        ) { [header] supplementaryView, _, _ in
            supplementaryView.configure(with: header)
        }
    }

    private func makeHeaderRegistration() -> UICollectionView.SupplementaryRegistration<SearchBucketHeaderView> {
        UICollectionView.SupplementaryRegistration<SearchBucketHeaderView>(
            elementKind: Self.bucketHeaderKind
        ) { [weak self] header, _, indexPath in
            guard let section = self?.dataSource?.snapshot().sectionIdentifiers[indexPath.section] else {
                return
            }
            header.configure(with: section)
        }
    }

    private func makeSnapshot(from sections: [SearchResultsSectionDisplayModel]) -> Snapshot {
        var snapshot = Snapshot()

        sections
            .forEach { sectionViewModel in
                let section = SearchResultsSectionIdentifier(
                    id: sectionViewModel.id,
                    title: sectionViewModel.title,
                    description: sectionViewModel.description
                )
                let items = sectionViewModel.items.map { cellViewModel in
                    SearchResultItemIdentifier(
                        id: cellViewModel.id,
                        displayModel: cellViewModel
                    )
                }

                snapshot.appendSections([section])
                snapshot.appendItems(items, toSection: section)
            }

        return snapshot
    }
}
