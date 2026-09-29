//
//  ProfileEditAnalyticsEvent.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 29.09.2026.
//

import Foundation

enum ProfileEditAnalyticsEvent {
    static func saveRequested(
        firstNameChanged: Bool,
        lastNameChanged: Bool,
        avatarChange: ProfileAvatarChange,
        avatarStyle: ProfileAvatarStyle
    ) -> AnalyticsEvent {
        let avatarAction: String
        
        switch avatarChange {
        case .unchanged:
            avatarAction = "unchanged"
        
        case .set:
            avatarAction = "set"
            
        case .clear:
            avatarAction = "clear"
        }
        
        return AnalyticsEvent(
            name: "profile_edit_save_requested",
            parameters: [
                "first_name_changed" : .integer(firstNameChanged ? 1 : 0),
                "last_name_changed": .integer(lastNameChanged ? 1 : 0),
                "avatar_action": .string(avatarAction),
                "avatar_style": .string(avatarStyle.rawValue.lowercased())
            ]
        )
    }
}
