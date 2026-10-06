import Foundation

@MainActor
final class MediaDetailsViewModel {
    enum State {
        case idle
        case loading
        case loaded(MediaDetailsDisplayModel)
        case failed(String)
    }

    private let context: MediaDetailsContext
    private let repository: MediaDetailsRepositoryProtocol
    private var requestGeneration = 0

    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }
    var onStateChange: ((State) -> Void)?

    init(context: MediaDetailsContext, repository: MediaDetailsRepositoryProtocol) {
        self.context = context
        self.repository = repository
    }

    func load() {
        requestGeneration += 1
        let generation = requestGeneration
        state = .loading

        repository.loadDetails(
            mediaId: context.mediaId,
            searchSessionId: context.searchSessionId
        ) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self, self.requestGeneration == generation else { return }
                switch result {
                case let .success(details):
                    self.state = .loaded(MediaDetailsDisplayModel(details: details))
                case let .failure(error):
                    self.state = .failed(error.userMessage)
                }
            }
        }
    }
}
