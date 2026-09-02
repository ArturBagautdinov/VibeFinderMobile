import Foundation

final class SearchRepository: SearchRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func search(
        query: String,
        completion: @escaping (Result<SearchPage, APIError>) -> Void
    ) {
        apiClient.request(.startSearch, body: SearchRequest(query: query)) { [apiClient] (result: Result<SearchStartedResponse, APIError>) in
            switch result {
            case let .success(response):
                Self.loadSearchPage(
                    id: response.searchSessionId,
                    apiClient: apiClient,
                    completion: completion
                )
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func loadHistory(
        completion: @escaping (Result<[SearchHistoryEntry], APIError>) -> Void
    ) {
        apiClient.request(.searchHistory) { (result: Result<[SearchHistoryEntryResponse], APIError>) in
            completion(result.map { $0.map { $0.toDomain() } })
        }
    }

    func loadSearchPage(
        id: Int,
        completion: @escaping (Result<SearchPage, APIError>) -> Void
    ) {
        Self.loadSearchPage(id: id, apiClient: apiClient, completion: completion)
    }

    private static func loadSearchPage(
        id: Int,
        apiClient: APIClientProtocol,
        completion: @escaping (Result<SearchPage, APIError>) -> Void
    ) {
        apiClient.request(.searchPage(id: id)) { (result: Result<SearchPageResponse, APIError>) in
            completion(result.map { $0.toDomain() })
        }
    }
}
