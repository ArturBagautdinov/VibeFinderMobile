import Foundation
import Testing
@testable import VibeFinderMobile

@Suite(.serialized)
struct EditProfileTests {
    @Test
    @MainActor
    func avatarRequestFollowsContract() throws {
        let symbol = ProfileAvatar(
            style: .symbol,
            symbol: "gamecontroller.fill",
            backgroundHex: "#4F46E5",
            foregroundHex: "#FFFFFF"
        )
        let color = ProfileAvatar(
            style: .color,
            symbol: nil,
            backgroundHex: "#22C55E",
            foregroundHex: nil
        )

        let symbolJSON = try json(for: .set(symbol))
        #expect(symbolJSON["avatarStyle"] as? String == "SYMBOL")
        #expect(symbolJSON["avatarSymbol"] as? String == "gamecontroller.fill")
        #expect(symbolJSON["avatarBackgroundColor"] as? String == "#4F46E5")
        #expect(symbolJSON["avatarForegroundColor"] as? String == "#FFFFFF")

        let colorJSON = try json(for: .set(color))
        #expect(colorJSON["avatarStyle"] as? String == "COLOR")
        #expect(colorJSON["avatarSymbol"] == nil)
        #expect(colorJSON["avatarBackgroundColor"] as? String == "#22C55E")
        #expect(colorJSON["avatarForegroundColor"] == nil)

        let clearJSON = try json(for: .clear)
        #expect(clearJSON["avatarStyle"] as? String == "NONE")
        #expect(clearJSON["avatarSymbol"] == nil)
        #expect(clearJSON["avatarBackgroundColor"] == nil)

        let unchangedJSON = try json(for: .unchanged)
        #expect(unchangedJSON["avatarStyle"] == nil)
    }

    @Test
    @MainActor
    func editingNameKeepsCurrentAvatar() {
        let repository = EditProfileRepositorySpy()
        let profile = profileFixture(avatar: .init(
            style: .symbol,
            symbol: "star.fill",
            backgroundHex: "#4F46E5",
            foregroundHex: "#FFFFFF"
        ))
        let viewModel = EditProfileViewModel(profile: profile, repository: repository)

        viewModel.setNames(firstName: " New ", lastName: "Name")
        #expect(viewModel.state.canSave)
        viewModel.save()

        #expect(repository.lastUpdate?.firstName == "New")
        if case .unchanged? = repository.lastUpdate?.avatarChange {
            // Avatar fields must be omitted, so the backend retains the current avatar.
        } else {
            Issue.record("Expected unchanged avatar")
        }
    }

    @Test
    @MainActor
    func clearingAvatarSendsNone() {
        let repository = EditProfileRepositorySpy()
        let profile = profileFixture(avatar: .init(
            style: .symbol,
            symbol: "star.fill",
            backgroundHex: "#4F46E5",
            foregroundHex: "#FFFFFF"
        ))
        let viewModel = EditProfileViewModel(profile: profile, repository: repository)

        viewModel.selectStyle(.none)
        #expect(viewModel.state.canSave)
        viewModel.save()

        if case .clear? = repository.lastUpdate?.avatarChange {
            // The request encoder turns this into avatarStyle: NONE.
        } else {
            Issue.record("Expected avatar removal")
        }
    }

    @MainActor
    private func json(for change: ProfileAvatarChange) throws -> [String: Any] {
        let update = ProfileUpdate(firstName: "Artur", lastName: "Bagautdinov", avatarChange: change)
        let data = try JSONEncoder().encode(ProfileUpdateRequest(update: update))
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    @MainActor
    private func profileFixture(avatar: ProfileAvatar?) -> UserProfile {
        UserProfile(
            email: "artur@example.com",
            username: "artur",
            firstName: "Artur",
            lastName: "Bagautdinov",
            displayName: "Artur Bagautdinov",
            avatar: avatar,
            emailVerified: true,
            pendingEmail: nil,
            createdAt: "2026-01-01T00:00:00Z"
        )
    }
}

private final class EditProfileRepositorySpy: ProfileRepositoryProtocol {
    var lastUpdate: ProfileUpdate?

    func loadProfile(completion: @escaping (Result<ProfilePage, APIError>) -> Void) {}
    func logout(completion: @escaping (Result<Void, APIError>) -> Void) {}
    func updateProfile(
        _ update: ProfileUpdate,
        completion: @escaping (Result<UserProfile, APIError>) -> Void
    ) {
        lastUpdate = update
    }
}
