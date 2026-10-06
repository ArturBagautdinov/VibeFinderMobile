import Foundation

struct MediaDetails: Sendable {
    let mediaId: Int
    let title: String
    let originalTitle: String?
    let mediaType: MediaType
    let releaseYear: Int?
    let imageUrl: URL?
    let shortDescription: String?
    let fullDescription: String?
    let rating: Double?
    let durationMinutes: Int?
    let seasonCount: Int?
    let pageCount: Int?
    let estimatedHours: Int?
    let ageRating: String?
    let genres: [String]
    let atmosphereTags: [String]
    let themeTags: [String]
    let platforms: [String]
    let explanation: String?
    let warning: String?
    let isFavorite: Bool
    let progressStatus: MediaProgressStatus?
    let completionLabel: String
    let isHidden: Bool
}
