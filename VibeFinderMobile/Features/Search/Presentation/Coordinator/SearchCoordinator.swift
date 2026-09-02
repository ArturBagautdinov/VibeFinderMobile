import UIKit
import Swinject

final class SearchCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let container: Container
    private let username: String

    init(
        navigationController: UINavigationController,
        container: Container,
        username: String
    ) {
        self.navigationController = navigationController
        self.container = container
        self.username = username
    }

    func start() {
        let viewModel = container.resolve(SearchViewModel.self, argument: username)!
        let viewController = SearchViewController(viewModel: viewModel)
        viewController.onResultsReady = { [weak self] page in
            self?.showResults(page)
        }
        viewController.onMoreSuggestionsSelected = { [weak self, weak viewController] suggestions in
            self?.showSuggestionsPicker(
                suggestions: suggestions,
                onSuggestionSelected: { suggestion in
                    viewController?.selectSuggestion(suggestion)
                },
                onSuggestionDeleted: { suggestion in
                    viewController?.deleteSuggestion(suggestion) ?? suggestions
                },
                onRestoreDefaultsSelected: {
                    viewController?.restoreDefaultSuggestions() ?? suggestions
                }
            )
        }
        viewController.onHistorySeeAllSelected = { [weak self] in
            self?.showHistory()
        }
        navigationController.setViewControllers([viewController], animated: true)
    }

    private func showResults(_ page: SearchPage) {
        let viewController = SearchResultsViewController(
            page: page,
            imageLoader: container.resolve(SearchResultImageLoading.self)!
        )
        viewController.onBackSelected = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showSuggestionsPicker(
        suggestions: [SearchSuggestionDisplayModel],
        onSuggestionSelected: @escaping (SearchSuggestionDisplayModel) -> Void,
        onSuggestionDeleted: @escaping (SearchSuggestionDisplayModel) -> [SearchSuggestionDisplayModel],
        onRestoreDefaultsSelected: @escaping () -> [SearchSuggestionDisplayModel]
    ) {
        let viewController = SearchSuggestionsPickerViewController(suggestions: suggestions)
        viewController.onSuggestionSelected = onSuggestionSelected
        viewController.onSuggestionDeleted = onSuggestionDeleted
        viewController.onRestoreDefaultsSelected = onRestoreDefaultsSelected
        navigationController.present(viewController, animated: true)
    }

    private func showHistory() {
        let viewController = SearchHistoryViewController(
            viewModel: container.resolve(SearchHistoryViewModel.self)!
        )
        viewController.onBackSelected = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        viewController.onResultsReady = { [weak self] page in
            self?.showResults(page)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}
