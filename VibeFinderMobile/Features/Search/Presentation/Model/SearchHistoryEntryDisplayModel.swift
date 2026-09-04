import Foundation

nonisolated struct SearchHistoryEntryDisplayModel: Hashable, Sendable {
    let id: Int
    let title: String
    let query: String
    let subtitle: String
}
