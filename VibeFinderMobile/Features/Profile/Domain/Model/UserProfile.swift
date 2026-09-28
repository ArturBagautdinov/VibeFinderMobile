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
    let avatar: ProfileAvatar?
    let emailVerified: Bool
    let pendingEmail: String?
    let createdAt: String

    var initials: String {
        let value = [firstName, lastName]
            .filter { !$0.isEmpty }
            .compactMap(\.first)
            .map(String.init)
            .joined()
        return value.isEmpty ? String(username.prefix(1)).uppercased() : value.uppercased()
    }
}
