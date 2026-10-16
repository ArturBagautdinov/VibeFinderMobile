import Alamofire
import Foundation
import Testing
@testable import VibeFinderMobile

@Suite(.serialized)
@MainActor
struct MediaDetailsTests {
    @Test
    func responseMapsAllContractFields() throws {
        let response = try JSONDecoder().decode(MediaDetailsResponse.self, from: makeResponseData())
        let details = try #require(response.toDomain())

        #expect(details.mediaId == 5)
        #expect(details.title == "Arrival")
        #expect(details.originalTitle == "Arrival")
        #expect(details.mediaType == .movie)
        #expect(details.releaseYear == 2016)
        #expect(details.imageUrl?.absoluteString == "https://image.tmdb.org/t/p/w500/example.jpg")
        #expect(details.shortDescription == "Short text")
        #expect(details.fullDescription == "Full text")
        #expect(details.rating == 8.1)
        #expect(details.durationMinutes == 116)
        #expect(details.seasonCount == nil)
        #expect(details.pageCount == nil)
        #expect(details.estimatedHours == nil)
        #expect(details.ageRating == "PG-13")
        #expect(details.genres == ["sci-fi"])
        #expect(details.atmosphereTags == ["thoughtful"])
        #expect(details.themeTags == ["memory"])
        #expect(details.platforms == ["Netflix"])
        #expect(details.explanation == "Why it fits")
        #expect(details.warning == nil)
        #expect(details.isFavorite == false)
        #expect(details.progressStatus == nil)
        #expect(details.completionLabel == "Not marked yet")
        #expect(details.isHidden == false)
    }

    @Test
    func responsePreservesNullableFieldsAndMapsProgress() throws {
        let data = try makeResponseData(overriding: [
            "mediaType": "BOOK",
            "originalTitle": NSNull(),
            "imageUrl": NSNull(),
            "shortDescription": NSNull(),
            "fullDescription": NSNull(),
            "rating": NSNull(),
            "durationMinutes": NSNull(),
            "ageRating": NSNull(),
            "explanation": NSNull(),
            "progressStatus": "IN_PROGRESS",
            "pageCount": 240,
            "favorite": true,
            "hidden": true
        ])
        let response = try JSONDecoder().decode(MediaDetailsResponse.self, from: data)
        let details = try #require(response.toDomain())

        #expect(details.mediaType == .book)
        #expect(details.originalTitle == nil)
        #expect(details.imageUrl == nil)
        #expect(details.shortDescription == nil)
        #expect(details.fullDescription == nil)
        #expect(details.rating == nil)
        #expect(details.durationMinutes == nil)
        #expect(details.ageRating == nil)
        #expect(details.explanation == nil)
        #expect(details.progressStatus == .inProgress)
        #expect(details.pageCount == 240)
        #expect(details.isFavorite)
        #expect(details.isHidden)
    }

    @Test
    func unknownContractEnumsDoNotBecomeEmptyState() throws {
        let unknownType = try JSONDecoder().decode(
            MediaDetailsResponse.self,
            from: makeResponseData(overriding: ["mediaType": "PODCAST"])
        )
        let unknownStatus = try JSONDecoder().decode(
            MediaDetailsResponse.self,
            from: makeResponseData(overriding: ["progressStatus": "UNKNOWN"])
        )

        #expect(unknownType.toDomain() == nil)
        #expect(unknownStatus.toDomain() == nil)
    }

    @Test
    func endpointUsesOptionalSearchContext() {
        let contextual = APIEndpoint.mediaDetails(id: 5, searchSessionId: 101)
        let standalone = APIEndpoint.mediaDetails(id: 5, searchSessionId: nil)

        #expect(contextual.path == "api/media/5")
        #expect(contextual.method == .get)
        #expect(contextual.requiresAuthorization)
        #expect(contextual.queryItems.map(\.name) == ["searchSessionId"])
        #expect(contextual.queryItems.map(\.value) == ["101"])
        #expect(standalone.queryItems.isEmpty)
    }

    @Test
    func repositoryRequestsDetailsAndMapsResponse() throws {
        let client = MediaDetailsAPIClientSpy()
        client.responseData = try makeResponseData()
        let repository = MediaDetailsRepository(apiClient: client)
        var received: Result<MediaDetails, APIError>?

        repository.loadDetails(mediaId: 5, searchSessionId: 101) { received = $0 }

        #expect(client.requestedEndpoint?.path == "api/media/5")
        #expect(client.requestedEndpoint?.queryItems.first?.value == "101")
        guard case let .success(details) = received else {
            Issue.record("Expected media details")
            return
        }
        #expect(details.mediaId == 5)
        #expect(details.explanation == "Why it fits")
    }

    @Test
    func repositoryForwardsNetworkErrorsAndRejectsUnknownEnums() throws {
        let client = MediaDetailsAPIClientSpy()
        let repository = MediaDetailsRepository(apiClient: client)
        client.error = .statusCode(404)
        var received: Result<MediaDetails, APIError>?

        repository.loadDetails(mediaId: 5, searchSessionId: nil) { received = $0 }
        guard case let .failure(.statusCode(code)) = received else {
            Issue.record("Expected HTTP error")
            return
        }
        #expect(code == 404)

        client.error = nil
        client.responseData = try makeResponseData(overriding: ["mediaType": "PODCAST"])
        repository.loadDetails(mediaId: 5, searchSessionId: nil) { received = $0 }
        guard case .failure(.decodingFailed) = received else {
            Issue.record("Expected decoding error for an unknown media type")
            return
        }
    }

    private func makeResponseData(overriding changes: [String: Any] = [:]) throws -> Data {
        var payload: [String: Any] = [
            "mediaId": 5,
            "title": "Arrival",
            "originalTitle": "Arrival",
            "mediaType": "MOVIE",
            "releaseYear": 2016,
            "imageUrl": "https://image.tmdb.org/t/p/w500/example.jpg",
            "shortDescription": "Short text",
            "fullDescription": "Full text",
            "rating": 8.1,
            "durationMinutes": 116,
            "seasonCount": NSNull(),
            "pageCount": NSNull(),
            "estimatedHours": NSNull(),
            "ageRating": "PG-13",
            "genres": ["sci-fi"],
            "atmosphereTags": ["thoughtful"],
            "themeTags": ["memory"],
            "platforms": ["Netflix"],
            "explanation": "Why it fits",
            "warning": NSNull(),
            "favorite": false,
            "progressStatus": NSNull(),
            "completionLabel": "Not marked yet",
            "hidden": false
        ]
        payload.merge(changes) { _, newValue in newValue }
        return try JSONSerialization.data(withJSONObject: payload)
    }
}

private final class MediaDetailsAPIClientSpy: APIClientProtocol {
    var responseData: Data?
    var error: APIError?
    private(set) var requestedEndpoint: APIEndpoint?

    func request<Response: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        body: Body,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        Issue.record("Media details request must not have a body")
        completion(.failure(.unknown))
    }

    func request<Response: Decodable>(
        _ endpoint: APIEndpoint,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        requestedEndpoint = endpoint
        if let error {
            completion(.failure(error))
            return
        }
        guard let responseData else {
            completion(.failure(.unknown))
            return
        }
        do {
            completion(.success(try JSONDecoder().decode(Response.self, from: responseData)))
        } catch {
            completion(.failure(.decodingFailed))
        }
    }
}
