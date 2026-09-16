//
//  ProfileRepository.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 09.09.2026.
//

import Foundation

final class ProfileRepository: ProfileRepositoryProtocol {
    
    private let apiClient: APIClientProtocol
    private let authRepository: AuthRepositoryProtocol
    
    init(
        apiClient: APIClientProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.apiClient = apiClient
        self.authRepository = authRepository
    }
    
    
    func loadProfile(completion: @escaping (Result<ProfilePage, APIError>) -> Void) {
        apiClient.request(.profile) { (result: Result<ProfileResponse, APIError>) in
            completion(result.map { $0.toDomain()})
        }
    }
    
    func logout(completion: @escaping (Result<Void, APIError>) -> Void) {
        authRepository.logout(completion: completion)
    }
    
}
