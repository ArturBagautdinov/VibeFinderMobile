//
//  ProfileUpdateRequest.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 25.09.2026.
//

import Foundation

struct ProfileUpdateRequest: Encodable {
    let firstName: String
    let lastName: String
    let avatarStyle: String?
    let avatarSymbol: String?
    let avatarBackgroundColor: String?
    let avatarForegroundColor: String?

    init(update: ProfileUpdate) {
        firstName = update.firstName
        lastName = update.lastName

        switch update.avatarChange {
        case .unchanged:
            avatarStyle = nil
            avatarSymbol = nil
            avatarBackgroundColor = nil
            avatarForegroundColor = nil

        case let .set(avatar):
            avatarStyle = avatar.style.rawValue
            avatarSymbol = avatar.style == .symbol ? avatar.symbol : nil
            avatarBackgroundColor = avatar.backgroundHex
            avatarForegroundColor = avatar.style == .symbol
                ? avatar.foregroundHex
                : nil

        case .clear:
            avatarStyle = ProfileAvatarStyle.none.rawValue
            avatarSymbol = nil
            avatarBackgroundColor = nil
            avatarForegroundColor = nil
        }
    }
}
