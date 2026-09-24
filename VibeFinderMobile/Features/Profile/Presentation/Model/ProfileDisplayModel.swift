//
//  ProfileDisplayModel.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 09.09.2026.
//

import Foundation

struct ProfileDisplayModel {
    let initials: String
    let displayName: String
    let username: String
    let email: String
    let emailStatus: String
    let summary: String
    let stats: [ProfileStatDisplayModel]
    let sections: [ProfileInfoSectionDisplayModel]
}
