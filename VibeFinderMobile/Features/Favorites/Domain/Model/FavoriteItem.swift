import Foundation

struct FavoriteItem: Sendable {
    let mediaId: Int
    let title: String
    let mediaType: MediaType
    let releaseYear: Int?
    let imageUrl: URL?
    let shortDescription: String?
}
