import UIKit

final class SearchHistoryViewController: UIViewController {
    private let viewModel: SearchHistoryViewModel
    private lazy var historyView = SearchHistoryView()

    var onBackSelected: (() -> Void)?
    var onResultsReady: ((SearchPage) -> Void)?

    init(viewModel: SearchHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = historyView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bindViewModel()
        viewModel.loadHistory()
    }

    private func configure() {
        navigationItem.title = nil
        navigationItem.hidesBackButton = true

        historyView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        historyView.onHistorySelected = { [weak self] history in
            self?.viewModel.selectHistory(id: history.id)
        }
        historyView.onHistoryDeleted = { [weak self] history in
            self?.viewModel.deleteHistoryItem(id: history.id)
        }
        historyView.onClearHistorySelected = { [weak self] in
            self?.showClearHistoryConfirmation()
        }
    }

    private func bindViewModel() {
        historyView.render(viewModel.state)
        viewModel.onStateChange = { [weak self] state in
            self?.historyView.render(state)
        }
        viewModel.onResultsReady = { [weak self] page in
            self?.onResultsReady?(page)
        }
    }

    @objc private func backTapped() {
        onBackSelected?()
    }

    private func showClearHistoryConfirmation() {
        let alertController = UIAlertController(
            title: L10n.Search.History.Clear.title,
            message: L10n.Search.History.Clear.message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alertController.addAction(
            UIAlertAction(
                title: L10n.Search.History.Clear.button,
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.clearHistory()
            }
        )
        present(alertController, animated: true)
    }
}
