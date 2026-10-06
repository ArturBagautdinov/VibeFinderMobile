import Foundation

struct MediaDetailsTagGroupDisplayModel {
    let title: String
    let symbol: String
    let tags: [String]
}

struct MediaDetailsDisplayModel {
    let title: String
    let originalTitle: String?
    let mediaType: String
    let releaseYear: String?
    let imageURL: URL?
    let fallbackSymbol: String
    let artworkStartsBelowSafeArea: Bool
    let rating: String?
    let facts: [String]
    let description: String?
    let explanation: String?
    let warning: String?
    let tagGroups: [MediaDetailsTagGroupDisplayModel]

    init(details: MediaDetails) {
        title = details.title
        originalTitle = Self.nonEmpty(details.originalTitle).flatMap {
            $0 == details.title ? nil : $0
        }
        imageURL = details.imageUrl
        artworkStartsBelowSafeArea = details.mediaType == .game
        releaseYear = details.releaseYear.map(String.init)
        description = Self.nonEmpty(details.fullDescription)
            ?? Self.nonEmpty(details.shortDescription)
        explanation = Self.nonEmpty(details.explanation)
        warning = Self.nonEmpty(details.warning)

        switch details.mediaType {
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

        if let rating = details.rating {
            let formatter = NumberFormatter()
            formatter.locale = .current
            formatter.maximumFractionDigits = 1
            formatter.minimumFractionDigits = 0
            self.rating = formatter.string(from: NSNumber(value: rating)).map { "★ \($0)" }
        } else {
            self.rating = nil
        }

        var facts: [String] = []
        if let minutes = details.durationMinutes { facts.append(L10n.Media.Details.minutes(minutes)) }
        if let seasons = details.seasonCount { facts.append(L10n.Media.Details.seasons(seasons)) }
        if let pages = details.pageCount { facts.append(L10n.Media.Details.pages(pages)) }
        if let hours = details.estimatedHours { facts.append(L10n.Media.Details.hours(hours)) }
        if let ageRating = Self.nonEmpty(details.ageRating) { facts.append(ageRating) }
        self.facts = facts

        tagGroups = [
            MediaDetailsTagGroupDisplayModel(
                title: L10n.Media.Details.genres,
                symbol: "theatermasks.fill",
                tags: details.genres
            ),
            MediaDetailsTagGroupDisplayModel(
                title: L10n.Media.Details.atmospheres,
                symbol: "sparkles",
                tags: details.atmosphereTags
            ),
            MediaDetailsTagGroupDisplayModel(
                title: L10n.Media.Details.themes,
                symbol: "circle.grid.2x2.fill",
                tags: details.themeTags
            ),
            MediaDetailsTagGroupDisplayModel(
                title: L10n.Media.Details.platforms,
                symbol: "gamecontroller.fill",
                tags: details.platforms
            )
        ].filter { !$0.tags.isEmpty }
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
    }
}
