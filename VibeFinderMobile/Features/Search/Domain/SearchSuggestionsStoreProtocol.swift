protocol SearchSuggestionsStoreProtocol {
    func loadSuggestions() -> [SearchSuggestion]
    func saveSuggestions(_ suggestions: [SearchSuggestion])
}
