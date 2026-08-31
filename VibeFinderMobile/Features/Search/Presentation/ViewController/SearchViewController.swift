import UIKit

final class SearchViewController: UIViewController {
    private let viewModel: SearchViewModel
    private lazy var searchView = SearchView(state: viewModel.state)

    var onResultsReady: ((SearchPage) -> Void)?

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bindViewModel()
    }

    private func configure() {
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        searchView.submitButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        searchView.onSuggestionSelected = { [weak self] suggestion in
            self?.searchView.setPromptText(suggestion)
        }
        searchView.onCustomSuggestionSubmitted = { [weak self] suggestion in
            self?.viewModel.addCustomSuggestion(suggestion)
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.searchView.render(state)
        }
        viewModel.onResultsReady = { [weak self] page in
            self?.onResultsReady?(page)
        }
    }

    @objc private func searchTapped() {
        view.endEditing(true)
        viewModel.search(query: searchView.promptTextView.text)
    }
}
