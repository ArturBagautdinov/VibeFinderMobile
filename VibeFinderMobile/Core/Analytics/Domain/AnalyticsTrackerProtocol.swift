//
//  AnalyticsTrackerProtocol.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 29.09.2026.
//

import Foundation

protocol AnalyticsTrackerProtocol {
    func track(_ event: AnalyticsEvent)
}
