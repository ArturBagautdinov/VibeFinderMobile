//
//  FirebaseSearchPerformanceTracker.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 05.10.2026.
//

import Foundation
import FirebasePerformance

final class FirebaseSearchPerformanceTracker: SearchPerformanceTracking {

    func startSearchToResults() -> SearchPerformanceTrace? {
        guard let trace = Performance.startTrace(name: "search_to_results") else {
            return nil
        }

        return FirebaseSearchPerformanceTrace(trace: trace)
    }
}

private final class FirebaseSearchPerformanceTrace: SearchPerformanceTrace {
    private var trace: Trace?

    init(trace: Trace) {
        self.trace = trace
    }

    func finish(outcome: SearchPerformanceOutcome) {
        guard let trace else { return }

        trace.setValue(outcome.rawValue, forAttribute: "outcome")
        trace.stop()
        self.trace = nil
    }
}
