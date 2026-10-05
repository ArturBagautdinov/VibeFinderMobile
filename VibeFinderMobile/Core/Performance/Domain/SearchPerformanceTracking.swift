//
//  SearchPerformanceTracking.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 05.10.2026.
//

import Foundation

protocol SearchPerformanceTracking {
    func startSearchToResults() -> SearchPerformanceTrace?
}

protocol SearchPerformanceTrace: AnyObject {
    func finish(outcome: SearchPerformanceOutcome)
}

enum SearchPerformanceOutcome: String {
    case shown
    case failed
    case cancelled
}
