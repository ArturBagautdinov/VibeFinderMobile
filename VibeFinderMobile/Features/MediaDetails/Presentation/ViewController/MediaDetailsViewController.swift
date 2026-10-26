import UIKit

final class MediaDetailsViewController: UIViewController, AlertPresenting {
    private let viewModel: MediaDetailsViewModel
    private let imageLoader: RemoteImageLoading
    private let backAccessibilityLabel: String
    private lazy var detailsView = MediaDetailsView(imageLoader: imageLoader)

    var onBackSelected: (() -> Void)?

    init(
        viewModel: MediaDetailsViewModel,
        imageLoader: RemoteImageLoading,
        backAccessibilityLabel: String = L10n.Media.Details.back
    ) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        self.backAccessibilityLabel = backAccessibilityLabel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = detailsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        detailsView.backButton.accessibilityLabel = backAccessibilityLabel
        detailsView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        detailsView.retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        detailsView.favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        viewModel.onFavoriteError = { [weak self] message in
            self?.showAlert(title: L10n.Media.Details.favoriteErrorTitle, message: message)
        }
        viewModel.load()
    }

    private func render(_ state: MediaDetailsViewModel.State) {
        switch state {
        case .idle, .loading:
            detailsView.showLoading()
        case let .loaded(model):
            detailsView.showContent(model)
        case let .failed(message):
            detailsView.showError(message)
        }
    }

    @objc private func backTapped() {
        onBackSelected?()
    }

    @objc private func retryTapped() {
        viewModel.load()
    }

    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
}
