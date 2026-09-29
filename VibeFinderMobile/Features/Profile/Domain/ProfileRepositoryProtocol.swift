//
//  ProfileRepositoryProtocol.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 09.09.2026.
//

import Foundation

protocol ProfileRepositoryProtocol {
    func loadProfile(completion: @escaping (Result<ProfilePage, APIError>) -> Void)
    func logout(completion: @escaping (Result<Void, APIError>) -> Void)
    func updateProfile(
        _ update: ProfileUpdate,
        completion: @escaping (Result<UserProfile, APIError>) -> Void
    )
}
