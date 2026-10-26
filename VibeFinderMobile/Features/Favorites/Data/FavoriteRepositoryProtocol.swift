protocol FavoriteRepositoryProtocol {
    func loadFavorites(
        completion: @escaping (Result<[FavoriteItem], APIError>) -> Void
    )

    func setFavorite(
        mediaId: Int,
        isFavorite: Bool,
        completion: @escaping (Result<Bool, APIError>) -> Void
    )
}
