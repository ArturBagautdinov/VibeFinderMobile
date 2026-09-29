import Foundation

struct EditProfileDraft {
    var firstName: String
    var lastName: String
    var avatar: ProfileAvatar?
    var selectedSymbol: String
    var selectedColor: String

    init(profile: UserProfile) {
        firstName = profile.firstName
        lastName = profile.lastName
        avatar = profile.avatar
        selectedSymbol = profile.avatar?.symbol ?? "sparkles"
        selectedColor = profile.avatar?.backgroundHex ?? "#4F46E5"
    }
}
