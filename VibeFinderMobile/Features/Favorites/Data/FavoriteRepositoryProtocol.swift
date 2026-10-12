protocol FavoriteRepositoryProtocol {
    func setFavorite(
        mediaId: Int,
        isFavorite: Bool,
        completion: @escaping (Result<Bool, APIError>) -> Void
    )
}
