//
//  UserProfile.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 09.09.2026.
//

import Foundation

struct UserProfile: Equatable {
    let email: String
    let username: String
    let firstName: String
    let lastName: String
    let displayName: String
    let avatarUrl: URL?
    let emailVerified: Bool
    let pendingEmail: String?
    let createdAt: String
}
