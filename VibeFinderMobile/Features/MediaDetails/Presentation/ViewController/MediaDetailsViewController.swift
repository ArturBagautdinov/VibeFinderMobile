import UIKit

final class MediaDetailsViewController: UIViewController {
    private let viewModel: MediaDetailsViewModel
    private let imageLoader: RemoteImageLoading
    private lazy var detailsView = MediaDetailsView(imageLoader: imageLoader)

    var onBackSelected: (() -> Void)?

    init(viewModel: MediaDetailsViewModel, imageLoader: RemoteImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
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
        detailsView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        detailsView.retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
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
}
