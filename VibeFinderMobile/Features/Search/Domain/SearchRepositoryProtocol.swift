import Foundation

protocol SearchRepositoryProtocol {
    func search(
        query: String,
        completion: @escaping (Result<SearchPage, APIError>) -> Void
    )
}

struct SearchPage {
    let id: Int
    let originalQuery: String
    let refinedQuery: String?
    let summary: String
    let quickRefinements: [String]
    let buckets: [SearchBucket]
}

struct SearchBucket {
    let code: String
    let title: String
    let description: String
    let items: [SearchRecommendation]
}

struct SearchRecommendation {
    let mediaId: Int
    let title: String
    let mediaType: String
    let releaseYear: Int?
    let imageUrl: URL?
    let genres: [String]
    let shortDescription: String
    let overallMatch: Int
    let explanation: String
    let warning: String?
    let rating: Double?
    let completionLabel: String?
}
