//
//  KeychainStorageError.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 25.08.2026.
//

import Foundation

enum KeychainStorageError: Error {
    case unhandledStatus(OSStatus)
    case invalidData
}
