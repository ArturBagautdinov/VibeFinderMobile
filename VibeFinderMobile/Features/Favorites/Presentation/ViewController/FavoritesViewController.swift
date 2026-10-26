import UIKit

final class FavoritesViewController: UIViewController {
    var onFavoriteSelected: ((Int) -> Void)?

    private let viewModel: FavoritesViewModel
    private let imageLoader: RemoteImageLoading
    private lazy var favoritesView = FavoritesView(imageLoader: imageLoader)

    init(viewModel: FavoritesViewModel, imageLoader: RemoteImageLoading) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = favoritesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesView.onRefreshRequested = { [weak self] in
            self?.viewModel.loadFavorites()
        }
        favoritesView.onFavoriteSelected = { [weak self] mediaId in
            self?.onFavoriteSelected?(mediaId)
        }
        favoritesView.render(viewModel.state)
        viewModel.onStateChange = { [weak self] state in
            self?.favoritesView.render(state)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }
}
