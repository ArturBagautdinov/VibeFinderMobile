protocol MediaDetailsRepositoryProtocol {
    func loadDetails(
        mediaId: Int,
        searchSessionId: Int?,
        completion: @escaping (Result<MediaDetails, APIError>) -> Void
    )
}
