//
//  KeychainStoring.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 25.08.2026.
//

import Foundation

protocol KeychainStoring {
    func save(_ value: String, for key: String) throws
    func read(_ key: String) throws -> String?
    func delete(_ key: String) throws
}
