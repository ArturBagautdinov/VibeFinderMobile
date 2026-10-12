final class FavoriteRepository: FavoriteRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func setFavorite(
        mediaId: Int,
        isFavorite: Bool,
        completion: @escaping (Result<Bool, APIError>) -> Void
    ) {
        let endpoint = isFavorite
            ? APIEndpoint.addFavorite(mediaId: mediaId)
            : APIEndpoint.removeFavorite(mediaId: mediaId)

        apiClient.request(endpoint) { (result: Result<FavoriteActionResponse, APIError>) in
            switch result {
            case let .success(response):
                guard response.mediaId == mediaId else {
                    completion(.failure(.decodingFailed))
                    return
                }
                completion(.success(response.favorite))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
