import Alamofire
import Foundation
import Testing
@testable import VibeFinderMobile

@Suite(.serialized)
struct FavoriteRepositoryTests {
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
