import Foundation

@MainActor
final class SearchHistoryViewModel {
    struct State {
        let history: [SearchHistoryEntryDisplayModel]
        let isEmpty: Bool
        let isInitialLoading: Bool
        let isMutating: Bool
        let errorMessage: String?
    }

    private let searchRepository: SearchRepositoryProtocol
    private let analyticsTracker: AnalyticsTrackerProtocol
    private var historyEntries: [SearchHistoryEntry] = []
    private(set) var state: State

    var onStateChange: ((State) -> Void)?
    var onResultsReady: ((SearchPage) -> Void)?

    init(
        searchRepository: SearchRepositoryProtocol,
        analyticsTracker: AnalyticsTrackerProtocol
    ) {
        self.searchRepository = searchRepository
        self.analyticsTracker = analyticsTracker
        self.state = Self.makeState(from: [])
    }

    func loadHistory() {
        update(isInitialLoading: true, errorMessage: nil)
        searchRepository.loadHistory { [weak self] result in
            Task {
                switch result {
                case let .success(history):
                    self?.historyEntries = history
                    self?.update(history: history, isInitialLoading: false, errorMessage: nil)
                case let .failure(error):
                    self?.historyEntries = []
                    self?.update(history: [], isInitialLoading: false, errorMessage: error.userMessage)
                }
            }
        }
    }

    func selectHistory(id: Int) {
        analyticsTracker.track(SearchHistoryAnalyticsEvent.openRequested(source: .full))
        update(isInitialLoading: true, errorMessage: nil)
        let tracker = analyticsTracker
        searchRepository.loadSearchPage(id: id) { [weak self, tracker] result in
            Task {
                switch result {
                case let .success(page):
                    tracker.track(SearchHistoryAnalyticsEvent.openSucceeded(source: .full))
                    self?.update(isInitialLoading: false, errorMessage: nil)
                    self?.onResultsReady?(page)
                case let .failure(error):
                    tracker.track(SearchHistoryAnalyticsEvent.openFailed(source: .full, error: error))
                    self?.update(isInitialLoading: false, errorMessage: error.userMessage)
                }
            }
        }
    }

    func deleteHistoryItem(id: Int) {
        let previousHistoryEntries = historyEntries
        historyEntries.removeAll { $0.id == id }
        update(history: historyEntries, isMutating: true, errorMessage: nil)

        searchRepository.deleteHistoryItem(id: id) { [weak self] result in
            Task {
                switch result {
                case .success:
                    self?.update(isMutating: false, errorMessage: nil)
                case let .failure(error):
                    self?.historyEntries = previousHistoryEntries
                    self?.update(history: previousHistoryEntries, isMutating: false, errorMessage: error.userMessage)
                }
            }
        }
    }

    func clearHistory() {
        let previousHistoryEntries = historyEntries
        historyEntries = []
        update(history: [], isMutating: true, errorMessage: nil)

        searchRepository.clearHistory { [weak self] result in
            Task {
                switch result {
                case .success:
                    self?.update(isMutating: false, errorMessage: nil)
                case let .failure(error):
                    self?.historyEntries = previousHistoryEntries
                    self?.update(history: previousHistoryEntries, isMutating: false, errorMessage: error.userMessage)
                }
            }
        }
    }

    private func update(
        history: [SearchHistoryEntry]? = nil,
        isInitialLoading: Bool? = nil,
        isMutating: Bool? = nil,
        errorMessage: String? = nil
    ) {
        let displayHistory = history.map(SearchHistoryDisplayModelMapper.makeDisplayModels) ?? state.history
        state = State(
            history: displayHistory,
            isEmpty: displayHistory.isEmpty,
            isInitialLoading: isInitialLoading ?? state.isInitialLoading,
            isMutating: isMutating ?? state.isMutating,
            errorMessage: errorMessage
        )
        onStateChange?(state)
    }

    private static func makeState(from entries: [SearchHistoryEntry]) -> State {
        let history = SearchHistoryDisplayModelMapper.makeDisplayModels(from: entries)
        return State(
            history: history,
            isEmpty: history.isEmpty,
            isInitialLoading: false,
            isMutating: false,
            errorMessage: nil
        )
    }
}
