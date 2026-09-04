
import Foundation

struct SearchPage {
    let id: Int
    let originalQuery: String
    let refinedQuery: String?
    let summary: String
    let quickRefinements: [String]
    let buckets: [SearchBucket]
}
