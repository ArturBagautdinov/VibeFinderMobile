import Foundation

final class UserDefaultsSearchSuggestionsStore: SearchSuggestionsStoreProtocol {
    private enum Constants {
        static let suggestionsKey = "search.suggestions"
    }

    private let userDefaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func loadSuggestions() -> [SearchSuggestion] {
        guard
            let data = userDefaults.data(forKey: Constants.suggestionsKey),
            let suggestions = try? decoder.decode([SearchSuggestion].self, from: data),
            !suggestions.isEmpty
        else {
            let suggestions = SearchSuggestion.defaults
            saveSuggestions(suggestions)
            return suggestions
        }

        return suggestions
    }

    func saveSuggestions(_ suggestions: [SearchSuggestion]) {
        guard let data = try? encoder.encode(suggestions) else {
            return
        }

        userDefaults.set(data, forKey: Constants.suggestionsKey)
    }
}
