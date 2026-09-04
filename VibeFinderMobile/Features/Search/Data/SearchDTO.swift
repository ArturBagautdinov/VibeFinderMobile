import Foundation

struct SearchRequest: Encodable {
    let query: String
}

struct SearchStartedResponse: Decodable {
    let searchSessionId: Int
}

struct SearchPageResponse: Decodable {
    let id: Int
    let originalQuery: String
    let refinedQuery: String?
    let summary: String
    let quickRefinements: [String]
    let buckets: [SearchBucketResponse]
}

struct SearchHistoryEntryResponse: Decodable {
    let id: Int
    let originalQuery: String
    let refinedQuery: String?
    let resultCount: Int
    let createdAtDisplay: String

    private enum CodingKeys: String, CodingKey {
        case id
        case originalQuery
        case refinedQuery
        case resultCount
        case createdAtDisplay
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        originalQuery = try container.decodeIfPresent(String.self, forKey: .originalQuery) ?? ""
        refinedQuery = try container.decodeIfPresent(String.self, forKey: .refinedQuery)
        resultCount = try container.decodeIfPresent(Int.self, forKey: .resultCount) ?? 0
        createdAtDisplay = try container.decodeIfPresent(String.self, forKey: .createdAtDisplay) ?? ""
    }
}

struct SearchBucketResponse: Decodable {
    let code: String
    let title: String
    let description: String
    let items: [SearchRecommendationResponse]
}

struct SearchRecommendationResponse: Decodable {
    let mediaId: Int
    let title: String
    let mediaType: String
    let releaseYear: Int?
    let imageUrl: String?
    let genres: [String]
    let shortDescription: String?
    let shortDescriptionDisplay: String?
    let overallMatch: Int
    let explanation: String
    let warning: String?
    let rating: Double?
    let completionLabel: String?
}

extension SearchPageResponse {
    func toDomain() -> SearchPage {
        SearchPage(
            id: id,
            originalQuery: originalQuery,
            refinedQuery: refinedQuery,
            summary: summary,
            quickRefinements: quickRefinements,
            buckets: buckets.map { $0.toDomain() }
        )
    }
}

extension SearchHistoryEntryResponse {
    func toDomain() -> SearchHistoryEntry {
        SearchHistoryEntry(
            id: id,
            originalQuery: originalQuery,
            refinedQuery: refinedQuery,
            resultCount: resultCount,
            createdAtDisplay: createdAtDisplay
        )
    }
}

private extension SearchBucketResponse {
    func toDomain() -> SearchBucket {
        SearchBucket(
            code: code,
            title: title,
            description: description,
            items: items.map { $0.toDomain() }
        )
    }
}

private extension SearchRecommendationResponse {
    func toDomain() -> SearchRecommendation {
        SearchRecommendation(
            mediaId: mediaId,
            title: title,
            mediaType: mediaType,
            releaseYear: releaseYear,
            imageUrl: imageUrl.flatMap(URL.init(string:)),
            genres: genres,
            shortDescription: shortDescriptionDisplay ?? shortDescription ?? "",
            overallMatch: overallMatch,
            explanation: explanation,
            warning: warning,
            rating: rating,
            completionLabel: completionLabel
        )
    }
}
