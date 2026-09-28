import Foundation

enum ProfileAvatarStyle: String, Equatable {
    case symbol = "SYMBOL"
    case color = "COLOR"
    case none = "NONE"
}

struct ProfileAvatar: Equatable {
    let style: ProfileAvatarStyle
    let symbol: String?
    let backgroundHex: String?
    let foregroundHex: String?
}
