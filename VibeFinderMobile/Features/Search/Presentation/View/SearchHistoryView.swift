import UIKit

final class SearchHistoryView: UIView {
    let backButton = UIButton(type: .system)
    var onHistorySelected: ((SearchHistoryEntryDisplayModel) -> Void)?

    private let statusView = SearchStatusView()
    private let loadingView = SearchLoadingView()
    private let emptyView = SearchHistoryEmptyView()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeCollectionViewLayout()
    )
    private lazy var dataSource = makeDataSource()

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, SearchHistoryEntryDisplayModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SearchHistoryEntryDisplayModel>

    private nonisolated enum Section: Hashable {
        case main
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = AppTheme.Color.background
        accessibilityIdentifier = "search.history.screen"
        configureCollectionView()

        let contentStackView = UIStackView(arrangedSubviews: [
            makeHeader(),
            statusView,
            collectionView
        ])
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStackView)
        addSubview(emptyView)
        addSubview(loadingView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 18),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),

            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func render(_ state: SearchHistoryViewModel.State) {
        applySnapshot(with: state.history)
        emptyView.isHidden = !state.isEmpty
        collectionView.isHidden = state.isEmpty
        statusView.setMessage(state.errorMessage)
        loadingView.setVisible(state.isLoading)
    }

    private func makeHeader() -> UIView {
        configureBackButton()

        let titleLabel = UILabel()
        titleLabel.text = L10n.Search.Recent.fullTitle
        titleLabel.font = .systemFont(ofSize: 34, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView(arrangedSubviews: [backButton, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16

        return stackView
    }

    private func configureBackButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "chevron.left")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        configuration.baseBackgroundColor = AppTheme.Color.surface
        configuration.baseForegroundColor = AppTheme.Color.primary
        configuration.cornerStyle = .capsule
        backButton.configuration = configuration
        backButton.accessibilityIdentifier = "search.history.backButton"
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = AppTheme.Color.border.cgColor
        backButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor).isActive = true
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(80)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(80)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 14
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 28, trailing: 0)
            return section
        }
    }

    private func makeDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<
            SearchHistoryRowCell,
            SearchHistoryEntryDisplayModel
        > { [weak self] cell, _, history in
            cell.configure(with: history) {
                self?.onHistorySelected?(history)
            }
        }

        return DataSource(collectionView: collectionView) {
            collectionView, indexPath, history -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: history
            )
        }
    }

    private func applySnapshot(with history: [SearchHistoryEntryDisplayModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(history, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
