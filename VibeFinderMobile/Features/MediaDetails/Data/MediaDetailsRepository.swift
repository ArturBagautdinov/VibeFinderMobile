final class MediaDetailsRepository: MediaDetailsRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadDetails(
        mediaId: Int,
        searchSessionId: Int?,
        completion: @escaping (Result<MediaDetails, APIError>) -> Void
    ) {
        apiClient.request(.mediaDetails(id: mediaId, searchSessionId: searchSessionId)) {
            (result: Result<MediaDetailsResponse, APIError>) in
            switch result {
            case let .success(response):
                guard let details = response.toDomain() else {
                    completion(.failure(.decodingFailed))
                    return
                }
                completion(.success(details))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
