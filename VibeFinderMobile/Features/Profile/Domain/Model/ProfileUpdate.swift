//
//  ProfileUpdate.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 25.09.2026.
//

import Foundation

enum ProfileAvatarChange {
    case unchanged
    case set(ProfileAvatar)
    case clear
}

struct ProfileUpdate {
    let firstName: String
    let lastName: String
    let avatarChange: ProfileAvatarChange
}
