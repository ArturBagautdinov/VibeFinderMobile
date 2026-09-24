//
//  ProfileDTO.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 09.09.2026.
//

import Foundation

struct ProfileResponse: Decodable {
    let profile: UserProfileResponse
    let tasteProfile: TasteProfileResponse
}

struct UserProfileResponse: Decodable {
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

struct TasteProfileResponse: Decodable {
    let profileSummary: String
    let preferredPace: String
    let favoriteGenres: [String]
    let favoriteThemes: [String]
    let favoriteAtmospheres: [String]
    let favoriteSettings: [String]
    let dislikedElements: [String]
    let completedCount: Int
    let inProgressCount: Int
    let hiddenCount: Int
}

extension ProfileResponse {
    func toDomain() -> ProfilePage {
        ProfilePage(
            profile: UserProfile(
                email: profile.email,
                username: profile.username,
                firstName: profile.firstName,
                lastName: profile.lastName,
                displayName: profile.displayName,
                avatarUrl: profile.avatarUrl,
                emailVerified: profile.emailVerified,
                pendingEmail: profile.pendingEmail,
                createdAt: profile.createdAt
            ),
            tasteProfile: TasteProfile(
                profileSummary: tasteProfile.profileSummary,
                preferredPace: tasteProfile.preferredPace,
                favoriteGenres: tasteProfile.favoriteGenres,
                favoriteThemes: tasteProfile.favoriteThemes,
                favoriteAtmospheres: tasteProfile.favoriteAtmospheres,
                favoriteSettings: tasteProfile.favoriteSettings,
                dislikedElements: tasteProfile.dislikedElements,
                completedCount: tasteProfile.completedCount,
                inProgressCount: tasteProfile.inProgressCount,
                hiddenCount: tasteProfile.hiddenCount
            )
        )
    }
}
