import Foundation

struct SearchHistoryEntry: Equatable {
    let id: Int
    let originalQuery: String
    let refinedQuery: String?
    let resultCount: Int
    let createdAtDisplay: String
}
