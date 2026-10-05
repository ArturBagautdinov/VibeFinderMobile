import UIKit

final class SearchResultsViewController: UIViewController, UICollectionViewDelegate {
    private let viewModel: SearchResultsViewModel
    private let imageLoader: SearchResultImageLoading
    private lazy var resultsView = SearchResultsView(page: viewModel.page)
    private var dataSource: SearchResultsDataSource?

    var onBackSelected: (() -> Void)?

    private var didApplyInitialSnapshot = false
    private var didAppear = false
    private var didReportFirstDisplay = false

    var onFirstDisplay: (() -> Void)?

    init(page: SearchPage, imageLoader: SearchResultImageLoading) {
        self.viewModel = SearchResultsViewModel(page: page)
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        reportFirstDisplayIfReady()
    }

    override func loadView() {
        view = resultsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)

        resultsView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        resultsView.collectionView.delegate = self

        let dataSource = SearchResultsDataSource(
            collectionView: resultsView.collectionView,
            header: viewModel.header,
            imageLoader: imageLoader
        )
        self.dataSource = dataSource
        dataSource.apply(sections: viewModel.sections) { [weak self] in
            self?.didApplyInitialSnapshot = true
            self?.reportFirstDisplayIfReady()
        }
    }

    private func reportFirstDisplayIfReady() {
        guard didAppear,
              didApplyInitialSnapshot,
              !didReportFirstDisplay else {
            return
        }

        didReportFirstDisplay = true
        let callback = onFirstDisplay
        onFirstDisplay = nil
        callback?()
    }

    @objc private func backTapped() {
        onBackSelected?()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        resultsView.updateStickySummaryVisibility(for: scrollView.contentOffset.y)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard elementKind == SearchResultsDataSource.bucketHeaderKind else {
            return
        }
        (view as? SearchBucketHeaderView)?.animateAppearanceIfNeeded()
    }
}
