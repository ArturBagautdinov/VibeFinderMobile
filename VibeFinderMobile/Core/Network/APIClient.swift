import Alamofire
import Foundation

final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: Session
    private let tokenStorage: TokenStorage?
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL, session: Session, tokenStorage: TokenStorage? = nil) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStorage = tokenStorage
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func request<Response: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        body: Body,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        guard let requestContext = makeRequestContext(for: endpoint) else {
            completion(.failure(.statusCode(401)))
            return
        }

        let request = session.request(
            requestContext.url,
            method: endpoint.method,
            parameters: body,
            encoder: JSONParameterEncoder(encoder: encoder),
            headers: requestContext.headers
        )
        .validate(statusCode: 200..<300)

        handleResponse(request, completion: completion)
    }

    func request<Response: Decodable>(
        _ endpoint: APIEndpoint,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        guard let requestContext = makeRequestContext(for: endpoint) else {
            completion(.failure(.statusCode(401)))
            return
        }

        let request = session.request(
            requestContext.url,
            method: endpoint.method,
            headers: requestContext.headers
        )
        .validate(statusCode: 200..<300)

        handleResponse(request, completion: completion)
    }

    private func handleResponse<Response: Decodable>(
        _ request: DataRequest,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        request.responseData { [decoder] response in
            switch response.result {
            case let .success(data):
                Self.decode(data, decoder: decoder, completion: completion)
            case let .failure(error):
                completion(.failure(Self.mapError(error, data: response.data, decoder: decoder)))
            }
        }
    }

    private func makeRequestContext(for endpoint: APIEndpoint) -> (url: URL, headers: HTTPHeaders)? {
        guard let url = makeURL(for: endpoint) else {
            return nil
        }

        var headers = endpoint.headers
        headers.update(HTTPHeader(name: "Accept-Language", value: APILanguage.preferredCode))

        if endpoint.requiresAuthorization {
            guard let accessToken = try? tokenStorage?.read()?.accessToken else {
                return nil
            }
            headers.update(.authorization(bearerToken: accessToken))
        }

        return (url, headers)
    }

    private func makeURL(for endpoint: APIEndpoint) -> URL? {
        let url = baseURL.appendingPathComponent(endpoint.path)
        guard !endpoint.queryItems.isEmpty else {
            return url
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = endpoint.queryItems
        return components?.url
    }

    private static func decode<Response: Decodable>(
        _ data: Data,
        decoder: JSONDecoder,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        if data.isEmpty, Response.self == EmptyResponse.self {
            completion(.success(EmptyResponse() as! Response))
            return
        }

        do {
            completion(.success(try decoder.decode(Response.self, from: data)))
        } catch {
            completion(.failure(.decodingFailed))
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

struct EmptyResponse: Decodable {
    init() {}
}

private enum APILanguage {
    static var preferredCode: String {
        let supportedCodes = Set(["en", "ru"])
        let preferredCode = Bundle.main.preferredLocalizations
            .lazy
            .compactMap {
                $0
                    .replacingOccurrences(of: "_", with: "-")
                    .split(separator: "-")
                    .first
                    .map(String.init)
            }
            .first

        guard let preferredCode, supportedCodes.contains(preferredCode) else {
            return "en"
        }

        return preferredCode
    }
}
