import Foundation

struct FavoriteItemDisplayModel: Equatable {
    let mediaId: Int
    let title: String
    let mediaType: String
    let releaseYear: String?
    let description: String?
    let imageURL: URL?
    let fallbackSymbol: String

    init(item: FavoriteItem) {
        mediaId = item.mediaId
        title = item.title
        releaseYear = item.releaseYear.map(String.init)
        imageURL = item.imageUrl
        description = item.shortDescription?.trimmingCharacters(in: .whitespacesAndNewlines)

        switch item.mediaType {
        case .movie:
            mediaType = L10n.Media.Details.movie
            fallbackSymbol = "film.fill"
        case .series:
            mediaType = L10n.Media.Details.series
            fallbackSymbol = "tv.fill"
        case .book:
            mediaType = L10n.Media.Details.book
            fallbackSymbol = "book.closed.fill"
        case .game:
            mediaType = L10n.Media.Details.game
            fallbackSymbol = "gamecontroller.fill"
        }
    }
}
