import UIKit
import Swinject

final class SearchCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let container: Container
    private let username: String
    private weak var searchViewModel: SearchViewModel?

    private let performanceTracker: SearchPerformanceTracking
    private var activeSearchTrace: SearchPerformanceTrace?

    init(
        navigationController: UINavigationController,
        container: Container,
        username: String
    ) {
        self.navigationController = navigationController
        self.container = container
        self.username = username
        self.performanceTracker = container.resolve(SearchPerformanceTracking.self)!
    }

    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        let viewModel = container.resolve(SearchViewModel.self, argument: username)!
        searchViewModel = viewModel
        let viewController = SearchViewController(viewModel: viewModel)

        viewModel.onSearchStarted = { [weak self] in
            guard let self else { return }

            self.finishSearchTrace(outcome: .cancelled)
            self.activeSearchTrace = self.performanceTracker.startSearchToResults()
        }

        viewModel.onSearchFailed = { [weak self] in
            self?.finishSearchTrace(outcome: .failed)
        }

        viewController.onResultsReady = { [weak self] page in
            self?.showResults(page, completesSearchTrace: true)
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

    func updateProfileAppearance(avatar: ProfileAvatar?, initials: String) {
        searchViewModel?.updateProfileAppearance(avatar: avatar, initials: initials)
    }

    private func showResults(
        _ page: SearchPage,
        completesSearchTrace: Bool = false
    ) {
        let viewController = SearchResultsViewController(
            page: page,
            imageLoader: container.resolve(RemoteImageLoading.self)!
        )
        viewController.onBackSelected = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        viewController.onMediaSelected = { [weak self] mediaId in
            self?.showMediaDetails(mediaId: mediaId, searchSessionId: page.id)
        }

        if completesSearchTrace {
            viewController.onFirstDisplay = { [weak self] in
                self?.finishSearchTrace(outcome: .shown)
            }
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    private func showMediaDetails(mediaId: Int, searchSessionId: Int) {
        let context = MediaDetailsContext(mediaId: mediaId, searchSessionId: searchSessionId)
        let viewModel = container.resolve(MediaDetailsViewModel.self, argument: context)!
        let viewController = MediaDetailsViewController(
            viewModel: viewModel,
            imageLoader: container.resolve(RemoteImageLoading.self)!
        )
        viewController.onBackSelected = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func finishSearchTrace(outcome: SearchPerformanceOutcome) {
        activeSearchTrace?.finish(outcome: outcome)
        activeSearchTrace = nil
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
