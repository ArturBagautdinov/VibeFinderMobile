import Foundation

protocol SearchRepositoryProtocol {
    func search(
        query: String,
        completion: @escaping (Result<SearchPage, APIError>) -> Void
    )
}
