import Foundation

protocol SearchRepositoryProtocol {
    func search(
        query: String,
        completion: @escaping (Result<SearchPage, APIError>) -> Void
    )

    func loadHistory(
        completion: @escaping (Result<[SearchHistoryEntry], APIError>) -> Void
    )

    func loadSearchPage(
        id: Int,
        completion: @escaping (Result<SearchPage, APIError>) -> Void
    )

    func deleteHistoryItem(
        id: Int,
        completion: @escaping (Result<Void, APIError>) -> Void
    )

    func clearHistory(
        completion: @escaping (Result<Void, APIError>) -> Void
    )
}
