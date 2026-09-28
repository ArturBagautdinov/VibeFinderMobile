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
    let avatar: AvatarResponse?
    let emailVerified: Bool
    let pendingEmail: String?
    let createdAt: String
}

struct AvatarResponse: Decodable {
    let style: String
    let symbol: String?
    let backgroundColor: String?
    let foregroundColor: String?
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
            profile: profile.toDomain(),
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

private extension AvatarResponse {
    func toDomain() -> ProfileAvatar? {
        guard let style = ProfileAvatarStyle(rawValue: style) else {
            return nil
        }

        guard style != .none else {
            return nil
        }

        return ProfileAvatar(
            style: style,
            symbol: symbol,
            backgroundHex: backgroundColor,
            foregroundHex: foregroundColor
        )
    }
}

extension UserProfileResponse {
    func toDomain() -> UserProfile {
        UserProfile(
            email: email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            displayName: displayName,
            avatar: avatar?.toDomain(),
            emailVerified: emailVerified,
            pendingEmail: pendingEmail,
            createdAt: createdAt
        )
    }
}
