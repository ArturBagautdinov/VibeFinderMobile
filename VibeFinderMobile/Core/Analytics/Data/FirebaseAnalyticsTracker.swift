//
//  FirebaseAnalyticsTracker.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 29.09.2026.
//

import Foundation
import FirebaseAnalytics

final class FirebaseAnalyticsTracker: AnalyticsTrackerProtocol {
    func track(_ event: AnalyticsEvent) {
        let parameters = event.parameters.mapValues(\.firebaseValue)
        
        Analytics.logEvent(
            event.name,
            parameters: parameters.isEmpty ? nil : parameters)
    }
}

private extension AnalyticsParameterValue {
    var firebaseValue: Any {
        switch self {
        case let .string(value):
            return value
            
        case let .integer(value):
            return value
            
        case let .double(value):
            return value
        }
    }
}
