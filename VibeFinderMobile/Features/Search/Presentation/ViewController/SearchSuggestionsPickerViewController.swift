import UIKit

final class SearchSuggestionsPickerViewController: UIViewController {
    private var suggestions: [SearchSuggestionDisplayModel]
    private lazy var suggestionsView = SearchSuggestionsPickerView(suggestions: suggestions)

    var onSuggestionSelected: ((SearchSuggestionDisplayModel) -> Void)?
    var onSuggestionDeleted: ((SearchSuggestionDisplayModel) -> [SearchSuggestionDisplayModel])?
    var onRestoreDefaultsSelected: (() -> [SearchSuggestionDisplayModel])?

    init(suggestions: [SearchSuggestionDisplayModel]) {
        self.suggestions = suggestions
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = suggestionsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSheet()
        bindView()
    }

    private func configureSheet() {
        guard let sheetPresentationController else {
            return
        }

        sheetPresentationController.detents = [.medium(), .large()]
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.preferredCornerRadius = 28
    }

    private func bindView() {
        suggestionsView.onSuggestionSelected = { [weak self] suggestion in
            self?.dismiss(animated: true) {
                self?.onSuggestionSelected?(suggestion)
            }
        }
        suggestionsView.onSuggestionDeleted = { [weak self] suggestion in
            guard let self else { return }

            self.suggestions = self.onSuggestionDeleted?(suggestion) ?? self.suggestions
            self.suggestionsView.render(self.suggestions)
        }
        suggestionsView.onRestoreDefaultsSelected = { [weak self] in
            guard let self else { return }

            self.suggestions = self.onRestoreDefaultsSelected?() ?? self.suggestions
            self.suggestionsView.render(self.suggestions)
        }
        suggestionsView.onCloseSelected = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
