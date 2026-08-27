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
                apiClient.request(.searchPage(id: response.searchSessionId)) { (pageResult: Result<SearchPageResponse, APIError>) in
                    completion(pageResult.map { $0.toDomain() })
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
