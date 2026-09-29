//
//  AnalyticsEvent.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 29.09.2026.
//

import Foundation

struct AnalyticsEvent: Equatable {
    let name: String
    let parameters: [String : AnalyticsParameterValue]
    
    init(
        name: String,
        parameters: [String : AnalyticsParameterValue] = [:]
    ) {
        self.name = name
        self.parameters = parameters
    }
}

enum AnalyticsParameterValue: Equatable {
    case string(String)
    case integer(Int)
    case double(Double)
}
