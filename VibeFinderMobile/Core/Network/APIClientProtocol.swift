//
//  APIClientProtocol.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 25.08.2026.
//

import Foundation

protocol APIClientProtocol {
    func request<Response: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        body: Body,
        completion: @escaping (Result<Response, APIError>) -> Void
    )

    func request<Response: Decodable>(
        _ endpoint: APIEndpoint,
        completion: @escaping (Result<Response, APIError>) -> Void
    )
}
