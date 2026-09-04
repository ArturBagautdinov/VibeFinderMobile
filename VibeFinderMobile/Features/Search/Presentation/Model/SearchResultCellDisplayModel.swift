
import Foundation

nonisolated struct SearchResultCellDisplayModel: Sendable {
    let id: String
    let title: String
    let meta: String
    let mediaType: String
    let matchText: String
    let imageURL: URL?
    let isTopMatch: Bool
}
