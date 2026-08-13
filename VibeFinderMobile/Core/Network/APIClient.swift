import Alamofire
import Foundation

protocol APIClientProtocol {
    func request<Response: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        body: Body,
        completion: @escaping (Result<Response, APIError>) -> Void
    )
}

final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: Session
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL, session: Session) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func request<Response: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        body: Body,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        let url = baseURL.appendingPathComponent(endpoint.path)
        let request = session.request(
            url,
            method: endpoint.method,
            parameters: body,
            encoder: JSONParameterEncoder(encoder: encoder),
            headers: endpoint.headers
        )
        .validate(statusCode: 200..<300)

        request.responseData { [decoder] response in
            switch response.result {
            case let .success(data):
                do {
                    completion(.success(try decoder.decode(Response.self, from: data)))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            case let .failure(error):
                completion(.failure(Self.mapError(error, data: response.data, decoder: decoder)))
            }
        }
    }

    private static func mapError(_ error: AFError, data: Data?, decoder: JSONDecoder) -> APIError {
        if let data, let response = try? decoder.decode(APIErrorResponse.self, from: data) {
            return .server(response)
        }

        if let statusCode = error.responseCode {
            return .statusCode(statusCode)
        }

        return .transport(error)
    }
}
