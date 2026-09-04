import Foundation

enum SearchHistoryDisplayModelMapper {
    static func makeDisplayModels(
        from entries: [SearchHistoryEntry]
    ) -> [SearchHistoryEntryDisplayModel] {
        entries.map { entry in
            SearchHistoryEntryDisplayModel(
                id: entry.id,
                title: entry.refinedQuery ?? entry.originalQuery,
                query: entry.originalQuery,
                subtitle: L10n.Search.Recent.itemSubtitle(
                    entry.resultCount,
                    entry.createdAtDisplay
                )
            )
        }
    }

    static func makeDisplayModel(from page: SearchPage) -> SearchHistoryEntryDisplayModel {
        SearchHistoryEntryDisplayModel(
            id: page.id,
            title: page.refinedQuery ?? page.originalQuery,
            query: page.originalQuery,
            subtitle: L10n.Search.Recent.itemSubtitle(
                page.buckets.reduce(0) { $0 + $1.items.count },
                DateFormatter.searchHistoryDisplay.string(from: Date())
            )
        )
    }
}

private extension DateFormatter {
    static let searchHistoryDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
