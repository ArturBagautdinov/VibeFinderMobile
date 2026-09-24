//
//  TasteProfile.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 09.09.2026.
//

import Foundation

struct TasteProfile: Equatable {
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
