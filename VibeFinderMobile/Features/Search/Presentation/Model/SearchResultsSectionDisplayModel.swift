
import Foundation

nonisolated struct SearchResultsSectionDisplayModel: Sendable {
    let id: String
    let title: String
    let description: String
    let items: [SearchResultCellDisplayModel]
}
