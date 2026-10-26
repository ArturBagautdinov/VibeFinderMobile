import Foundation

struct FavoriteItemResponse: Decodable {
    let mediaId: Int
    let title: String
    let mediaType: String
    let releaseYear: Int?
    let imageUrl: String?
    let shortDescription: String?
    let shortDescriptionDisplay: String?

    func toDomain() -> FavoriteItem? {
        guard let mediaType = MediaType(rawValue: mediaType) else { return nil }

        return FavoriteItem(
            mediaId: mediaId,
            title: title,
            mediaType: mediaType,
            releaseYear: releaseYear,
            imageUrl: imageUrl.flatMap(URL.init(string:)),
            shortDescription: shortDescriptionDisplay ?? shortDescription
        )
    }
}
