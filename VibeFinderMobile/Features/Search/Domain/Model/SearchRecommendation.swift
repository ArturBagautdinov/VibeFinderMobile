
import Foundation

struct SearchRecommendation: Sendable {
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
