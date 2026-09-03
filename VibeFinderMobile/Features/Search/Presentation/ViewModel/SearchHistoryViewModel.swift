import Foundation

@MainActor
final class SearchHistoryViewModel {
    struct State {
        let history: [SearchHistoryEntryDisplayModel]
        let isEmpty: Bool
        let isLoading: Bool
        let errorMessage: String?
    }

    private let searchRepository: SearchRepositoryProtocol
    private(set) var state: State

    var onStateChange: ((State) -> Void)?
    var onResultsReady: ((SearchPage) -> Void)?

    init(searchRepository: SearchRepositoryProtocol) {
        self.searchRepository = searchRepository
        self.state = Self.makeState(from: [])
    }

    func loadHistory() {
        update(isLoading: true, errorMessage: nil)
        searchRepository.loadHistory { [weak self] result in
            Task {
                switch result {
                case let .success(history):
                    self?.update(history: history, isLoading: false, errorMessage: nil)
                case let .failure(error):
                    self?.update(history: [], isLoading: false, errorMessage: error.userMessage)
                }
            }
        }
    }

    func selectHistory(id: Int) {
        update(isLoading: true, errorMessage: nil)
        searchRepository.loadSearchPage(id: id) { [weak self] result in
            Task {
                switch result {
                case let .success(page):
                    self?.update(isLoading: false, errorMessage: nil)
                    self?.onResultsReady?(page)
                case let .failure(error):
                    self?.update(isLoading: false, errorMessage: error.userMessage)
                }
            }
        }
    }

    private func update(
        history: [SearchHistoryEntry]? = nil,
        isLoading: Bool? = nil,
        errorMessage: String? = nil
    ) {
        let displayHistory = history.map(SearchHistoryDisplayModelMapper.makeDisplayModels) ?? state.history
        state = State(
            history: displayHistory,
            isEmpty: displayHistory.isEmpty,
            isLoading: isLoading ?? state.isLoading,
            errorMessage: errorMessage
        )
        onStateChange?(state)
    }

    private static func makeState(from entries: [SearchHistoryEntry]) -> State {
        let history = SearchHistoryDisplayModelMapper.makeDisplayModels(from: entries)
        return State(history: history, isEmpty: history.isEmpty, isLoading: false, errorMessage: nil)
    }
}
