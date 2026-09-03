import UIKit

final class SearchHistoryView: UIView {
    let backButton = UIButton(type: .system)
    let clearHistoryButton = UIButton(type: .system)
    var onHistorySelected: ((SearchHistoryEntryDisplayModel) -> Void)?
    var onHistoryDeleted: ((SearchHistoryEntryDisplayModel) -> Void)?
    var onClearHistorySelected: (() -> Void)?

    private let statusView = SearchStatusView()
    private let loadingView = SearchLoadingView()
    private let emptyView = SearchHistoryEmptyView()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeCollectionViewLayout()
    )
    private lazy var dataSource = makeDataSource()
    private var hasAnimatedInitialHistoryAppearance = false
    private var isInitialHistoryAppearancePending = false

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
            contentStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            emptyView.bottomAnchor.constraint(lessThanOrEqualTo: collectionView.bottomAnchor, constant: -28),

            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func render(_ state: SearchHistoryViewModel.State) {
        applySnapshot(with: state.history)
        emptyView.isHidden = !state.isEmpty
        collectionView.isUserInteractionEnabled = !state.isEmpty
        clearHistoryButton.isHidden = state.isEmpty
        clearHistoryButton.isEnabled = !state.isMutating
        statusView.setMessage(state.errorMessage)
        loadingView.setVisible(state.isInitialLoading)
        if !state.isInitialLoading {
            animateInitialHistoryAppearanceIfNeeded()
        }
    }

    private func makeHeader() -> UIView {
        configureBackButton()
        configureClearHistoryButton()

        let containerView = UIView()

        let titleLabel = UILabel()
        titleLabel.text = L10n.Search.Recent.fullTitle
        titleLabel.font = .systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true

        [backButton, titleLabel, clearHistoryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            clearHistoryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            clearHistoryButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: clearHistoryButton.leadingAnchor, constant: -12)
        ])

        return containerView
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

    private func configureClearHistoryButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "trash")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        configuration.baseBackgroundColor = AppTheme.Color.surface
        configuration.baseForegroundColor = UIColor.systemRed
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 9, bottom: 9, trailing: 9)
        clearHistoryButton.configuration = configuration
        clearHistoryButton.accessibilityIdentifier = "search.history.clearButton"
        clearHistoryButton.layer.borderWidth = 1
        clearHistoryButton.layer.borderColor = AppTheme.Color.accent.withAlphaComponent(0.32).cgColor
        clearHistoryButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        clearHistoryButton.heightAnchor.constraint(equalTo: clearHistoryButton.widthAnchor).isActive = true
        clearHistoryButton.addAction(
            UIAction { [weak self] _ in
                self?.onClearHistorySelected?()
            },
            for: .touchUpInside
        )
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.backgroundColor = .clear
        configuration.showsSeparators = false
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let history = self?.dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }

            let deleteAction = UIContextualAction(
                style: .destructive,
                title: L10n.Search.History.Delete.action
            ) { [weak self] _, _, completion in
                self?.onHistoryDeleted?(history)
                completion(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        return UICollectionViewCompositionalLayout.list(using: configuration)
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
        if !hasAnimatedInitialHistoryAppearance && !history.isEmpty {
            isInitialHistoryAppearancePending = true
            hasAnimatedInitialHistoryAppearance = true
            collectionView.alpha = 0
        }
        dataSource.apply(snapshot, animatingDifferences: !isInitialHistoryAppearancePending)
    }

    private func animateInitialHistoryAppearanceIfNeeded() {
        guard isInitialHistoryAppearancePending else {
            return
        }

        isInitialHistoryAppearancePending = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { [weak self] in
            guard let self else {
                return
            }

            self.collectionView.layoutIfNeeded()
            let visibleCells = self.collectionView.indexPathsForVisibleItems
                .sorted()
                .compactMap { self.collectionView.cellForItem(at: $0) }

            visibleCells.enumerated().forEach { index, cell in
                cell.alpha = 0
                cell.transform = CGAffineTransform(translationX: 0, y: 26)
                    .scaledBy(x: 0.94, y: 0.94)

                UIView.animate(
                    withDuration: 0.62,
                    delay: 0.09 * Double(index),
                    usingSpringWithDamping: 0.76,
                    initialSpringVelocity: 0.4,
                    options: [.curveEaseOut, .allowUserInteraction]
                ) {
                    cell.alpha = 1
                    cell.transform = .identity
                }
            }

            UIView.animate(
                withDuration: 0.18,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction]
            ) {
                self.collectionView.alpha = 1
            }
        }
    }
}
