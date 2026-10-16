import Foundation

struct MediaDetailsResponse: Decodable {
    let mediaId: Int
    let title: String
    let originalTitle: String?
    let mediaType: String
    let releaseYear: Int?
    let imageUrl: String?
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
    let favorite: Bool
    let progressStatus: String?
    let completionLabel: String
    let hidden: Bool

    func toDomain() -> MediaDetails? {
        guard let mediaType = MediaType(rawValue: mediaType) else {
            return nil
        }

        let mappedProgressStatus: MediaProgressStatus?
        if let progressStatus {
            guard let status = MediaProgressStatus(rawValue: progressStatus) else {
                return nil
            }
            mappedProgressStatus = status
        } else {
            mappedProgressStatus = nil
        }

        return MediaDetails(
            mediaId: mediaId,
            title: title,
            originalTitle: originalTitle,
            mediaType: mediaType,
            releaseYear: releaseYear,
            imageUrl: imageUrl.flatMap(URL.init(string:)),
            shortDescription: shortDescription,
            fullDescription: fullDescription,
            rating: rating,
            durationMinutes: durationMinutes,
            seasonCount: seasonCount,
            pageCount: pageCount,
            estimatedHours: estimatedHours,
            ageRating: ageRating,
            genres: genres,
            atmosphereTags: atmosphereTags,
            themeTags: themeTags,
            platforms: platforms,
            explanation: explanation,
            warning: warning,
            isFavorite: favorite,
            progressStatus: mappedProgressStatus,
            completionLabel: completionLabel,
            isHidden: hidden
        )
    }
}
