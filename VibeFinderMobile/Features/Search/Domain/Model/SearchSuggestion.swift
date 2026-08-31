import Foundation

enum BuiltInSearchSuggestion: String, Codable, CaseIterable {
    case cozyEvening
    case darkMystery
    case beautifulScifi
    case slowSunday
    case rainyNightMovie
    case cozyGame
    case emotionalScifi
    case somethingWeird
    case lateNightThriller
    case weekendAdventure
    case comfortBook
    case mindBendingStory
}

struct SearchSuggestion: Codable, Equatable {
    enum Kind: String, Codable {
        case builtIn
        case custom
    }

    let id: String
    let kind: Kind
    let title: String?

    static var defaults: [SearchSuggestion] {
        BuiltInSearchSuggestion.allCases.map {
            SearchSuggestion(id: $0.rawValue, kind: .builtIn, title: nil)
        }
    }

    static func custom(title: String) -> SearchSuggestion {
        SearchSuggestion(id: UUID().uuidString, kind: .custom, title: title)
    }
}
