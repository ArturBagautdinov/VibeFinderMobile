import UIKit

final class SearchViewController: UIViewController {
    private let viewModel: SearchViewModel
    private lazy var searchView = SearchView(state: viewModel.state)

    var onResultsReady: ((SearchPage) -> Void)?
    var onMoreSuggestionsSelected: (([SearchSuggestionDisplayModel]) -> Void)?
    var onHistorySeeAllSelected: (() -> Void)?

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadRecentHistory()
    }

    private func configure() {
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        searchView.submitButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        searchView.onSuggestionSelected = { [weak self] suggestion in
            self?.selectSuggestion(suggestion)
        }
        searchView.onSuggestionDeleted = { [weak self] suggestion in
            self?.deleteSuggestion(suggestion)
        }
        searchView.onCustomSuggestionSubmitted = { [weak self] suggestion in
            self?.viewModel.addCustomSuggestion(suggestion)
        }
        searchView.onMoreSuggestionsSelected = { [weak self] in
            guard let self else { return }
            self.onMoreSuggestionsSelected?(self.viewModel.state.allSuggestions)
        }
        searchView.onHistorySeeAllSelected = { [weak self] in
            self?.onHistorySeeAllSelected?()
        }
        searchView.onHistorySelected = { [weak self] history in
            self?.selectHistory(history)
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

    func selectSuggestion(_ suggestion: SearchSuggestionDisplayModel) {
        searchView.setPromptText(suggestion.title)
    }

    @discardableResult
    func deleteSuggestion(_ suggestion: SearchSuggestionDisplayModel) -> [SearchSuggestionDisplayModel] {
        viewModel.deleteSuggestion(id: suggestion.id)
        return viewModel.state.allSuggestions
    }

    func restoreDefaultSuggestions() -> [SearchSuggestionDisplayModel] {
        viewModel.restoreDefaultSuggestions()
        return viewModel.state.allSuggestions
    }

    func selectHistory(_ history: SearchHistoryEntryDisplayModel) {
        view.endEditing(true)
        searchView.setPromptText(history.query, shouldBecomeFirstResponder: false)
        viewModel.openHistoryResult(history)
    }
}
