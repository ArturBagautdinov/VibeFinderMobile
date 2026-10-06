import Foundation

final class SearchResultsViewModel {
    let page: SearchPage
    let header: SearchResultsHeaderDisplayModel
    let sections: [SearchResultsSectionDisplayModel]

    init(page: SearchPage) {
        self.page = page
        self.header = SearchResultsHeaderDisplayModel(
            title: L10n.Search.Results.title,
            summary: page.summary
        )
        let highestMatch = page.buckets
            .flatMap(\.items)
            .map(\.overallMatch)
            .max() ?? 0

        self.sections = page.buckets
            .filter { !$0.items.isEmpty }
            .map { bucket in
                SearchResultsSectionDisplayModel(
                    id: bucket.code,
                    title: bucket.title,
                    description: bucket.description,
                    items: bucket.items.map { recommendation in
                        SearchResultCellDisplayModel(
                            id: "\(bucket.code)-\(recommendation.mediaId)",
                            mediaId: recommendation.mediaId,
                            title: recommendation.title,
                            meta: Self.makeMetaText(for: recommendation),
                            mediaType: recommendation.mediaType.uppercased(),
                            matchText: recommendation.overallMatch == highestMatch
                                ? "★ \(recommendation.overallMatch)%"
                                : "\(recommendation.overallMatch)%",
                            imageURL: recommendation.imageUrl,
                            isTopMatch: recommendation.overallMatch == highestMatch
                        )
                    }
                )
            }
    }

    private static func makeMetaText(for recommendation: SearchRecommendation) -> String {
        let genre = recommendation.genres.first ?? recommendation.mediaType.capitalized
        if let releaseYear = recommendation.releaseYear {
            return "\(releaseYear) · \(genre)"
        }
        return genre
    }
}
