import Alamofire
import Foundation
import Testing
@testable import VibeFinderMobile

@Suite(.serialized)
struct FavoriteRepositoryTests {
    @Test
    func listRequestsAuthenticatedEndpointAndMapsContractFields() throws {
        let client = FavoriteAPIClientSpy()
        let repository = FavoriteRepository(apiClient: client)
        client.responseData = try JSONSerialization.data(withJSONObject: [
            favoriteItem(mediaId: 5, mediaType: "MOVIE", description: "Short text", display: "Display text"),
            favoriteItem(mediaId: 8, mediaType: "GAME", description: "Another text", display: NSNull())
        ])
        var received: Result<[FavoriteItem], APIError>?

        repository.loadFavorites { received = $0 }

        #expect(client.requestedEndpoint?.path == "api/favorites")
        #expect(client.requestedEndpoint?.method == .get)
        #expect(client.requestedEndpoint?.requiresAuthorization == true)
        #expect(client.requestedEndpoint?.queryItems.isEmpty == true)
        guard case let .success(items) = received else {
            Issue.record("Expected favorites list")
            return
        }
        #expect(items.map(\.mediaId) == [5, 8])
        #expect(items.map(\.mediaType) == [.movie, .game])
        #expect(items[0].title == "Arrival")
        #expect(items[0].releaseYear == 2016)
        #expect(items[0].imageUrl?.absoluteString == "https://image.tmdb.org/t/p/w500/example.jpg")
        #expect(items[0].shortDescription == "Display text")
        #expect(items[1].shortDescription == "Another text")
    }

    @Test
    func listAcceptsEmptyAndNullableFields() throws {
        let client = FavoriteAPIClientSpy()
        let repository = FavoriteRepository(apiClient: client)
        var received: Result<[FavoriteItem], APIError>?

        client.responseData = try JSONSerialization.data(withJSONObject: [])
        repository.loadFavorites { received = $0 }
        if case let .success(items) = received { #expect(items.isEmpty) }
        else { Issue.record("Expected empty favorites list") }

        var item = favoriteItem(mediaId: 5, mediaType: "BOOK", description: NSNull(), display: NSNull())
        item["releaseYear"] = NSNull()
        item["imageUrl"] = NSNull()
        client.responseData = try JSONSerialization.data(withJSONObject: [item])
        repository.loadFavorites { received = $0 }
        guard case let .success(items) = received else {
            Issue.record("Expected favorite with nullable fields")
            return
        }
        #expect(items[0].releaseYear == nil)
        #expect(items[0].imageUrl == nil)
        #expect(items[0].shortDescription == nil)
    }

    @Test
    func listRejectsUnknownMediaTypeAndForwardsNetworkError() throws {
        let client = FavoriteAPIClientSpy()
        let repository = FavoriteRepository(apiClient: client)
        var received: Result<[FavoriteItem], APIError>?

        client.responseData = try JSONSerialization.data(withJSONObject: [
            favoriteItem(mediaId: 5, mediaType: "MOVIE", description: "Text", display: "Text"),
            favoriteItem(mediaId: 8, mediaType: "PODCAST", description: "Text", display: "Text")
        ])
        repository.loadFavorites { received = $0 }
        if case .failure(.decodingFailed) = received {} else {
            Issue.record("Expected unknown media type to reject the whole list")
        }

        client.error = .statusCode(503)
        repository.loadFavorites { received = $0 }
        if case let .failure(.statusCode(code)) = received { #expect(code == 503) }
        else { Issue.record("Expected network error") }
    }

    @Test
    func addAndRemoveUseAuthenticatedEndpointsAndServerState() throws {
        let client = FavoriteAPIClientSpy()
        let repository = FavoriteRepository(apiClient: client)
        var received: Result<Bool, APIError>?

        client.responseData = try response(mediaId: 5, favorite: true)
        repository.setFavorite(mediaId: 5, isFavorite: true) { received = $0 }
        #expect(client.requestedEndpoint?.path == "api/favorites/5")
        #expect(client.requestedEndpoint?.method == .post)
        #expect(client.requestedEndpoint?.requiresAuthorization == true)
        #expect(client.requestedEndpoint?.queryItems.isEmpty == true)
        if case let .success(value) = received { #expect(value) }
        else { Issue.record("Expected favorite state") }

        client.responseData = try response(mediaId: 5, favorite: false)
        repository.setFavorite(mediaId: 5, isFavorite: false) { received = $0 }
        #expect(client.requestedEndpoint?.method == .delete)
        #expect(client.requestedEndpoint?.requiresAuthorization == true)
        if case let .success(value) = received { #expect(!value) }
        else { Issue.record("Expected unfavorited state") }
    }

    @Test
    func mismatchedMediaIdAndNetworkFailureAreNotAccepted() throws {
        let client = FavoriteAPIClientSpy()
        let repository = FavoriteRepository(apiClient: client)
        var received: Result<Bool, APIError>?

        client.responseData = try response(mediaId: 7, favorite: true)
        repository.setFavorite(mediaId: 5, isFavorite: true) { received = $0 }
        if case .failure(.decodingFailed) = received {} else {
            Issue.record("Expected mismatched response to fail")
        }

        client.error = .statusCode(503)
        repository.setFavorite(mediaId: 5, isFavorite: true) { received = $0 }
        if case let .failure(.statusCode(code)) = received { #expect(code == 503) }
        else { Issue.record("Expected network error") }
    }

    private func response(mediaId: Int, favorite: Bool) throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "mediaId": mediaId,
            "favorite": favorite,
            "message": "Updated"
        ])
    }

    private func favoriteItem(
        mediaId: Int,
        mediaType: String,
        description: Any,
        display: Any
    ) -> [String: Any] {
        [
            "mediaId": mediaId,
            "title": "Arrival",
            "mediaType": mediaType,
            "releaseYear": 2016,
            "imageUrl": "https://image.tmdb.org/t/p/w500/example.jpg",
            "shortDescription": description,
            "shortDescriptionDisplay": display
        ]
    }
}

private final class FavoriteAPIClientSpy: APIClientProtocol {
    var responseData: Data?
    var error: APIError?
    private(set) var requestedEndpoint: APIEndpoint?

    func request<Response: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        body: Body,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        Issue.record("Favorite request must not have a body")
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
        guard let responseData,
              let response = try? JSONDecoder().decode(Response.self, from: responseData) else {
            completion(.failure(.decodingFailed))
            return
        }
        completion(.success(response))
    }
}
