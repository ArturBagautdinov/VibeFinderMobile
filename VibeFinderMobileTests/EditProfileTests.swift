import Foundation
import Testing
import UIKit
@testable import VibeFinderMobile

@Suite(.serialized)
struct EditProfileTests {
    @Test
    @MainActor
    func avatarChoicesAreRenderable() {
        let symbols = EditProfileAvatarSymbols.names
        let colors = EditProfileAvatarColors.hexValues

        #expect(symbols.count == 32)
        #expect(colors.count == 20)
        #expect(Set(symbols).count == symbols.count)
        #expect(Set(colors).count == colors.count)
        for symbol in symbols {
            #expect(UIImage(systemName: symbol) != nil)
        }
        for color in colors {
            #expect(UIColor(hex: color) != nil)
        }
    }

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

    @Test
    @MainActor
    func profilePublishesAppearanceAfterLoadAndSave() async {
        let repository = EditProfileRepositorySpy()
        let original = profileFixture(avatar: nil)
        repository.loadPage = ProfilePage(
            profile: original,
            tasteProfile: TasteProfile(
                profileSummary: "",
                preferredPace: "",
                favoriteGenres: [],
                favoriteThemes: [],
                favoriteAtmospheres: [],
                favoriteSettings: [],
                dislikedElements: [],
                completedCount: 0,
                inProgressCount: 0,
                hiddenCount: 0
            )
        )
        let viewModel = ProfileViewModel(profileRepository: repository)
        var observedProfiles: [UserProfile] = []
        viewModel.onProfileChanged = { observedProfiles.append($0) }

        viewModel.loadProfileIfNeeded()
        viewModel.loadProfileIfNeeded()
        await Task.yield()
        await Task.yield()

        #expect(repository.loadCallCount == 1)
        #expect(observedProfiles == [original])

        let avatar = ProfileAvatar(
            style: .symbol,
            symbol: "star.fill",
            backgroundHex: "#4F46E5",
            foregroundHex: "#FFFFFF"
        )
        let updated = UserProfile(
            email: original.email,
            username: original.username,
            firstName: "New",
            lastName: "Name",
            displayName: "New Name",
            avatar: avatar,
            emailVerified: original.emailVerified,
            pendingEmail: original.pendingEmail,
            createdAt: original.createdAt
        )
        viewModel.applyUpdatedProfile(updated)

        #expect(observedProfiles == [original, updated])
        #expect(viewModel.state.profile?.avatar == avatar)
        #expect(updated.initials == "NN")
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
    var loadPage: ProfilePage?
    private(set) var loadCallCount = 0

    func loadProfile(completion: @escaping (Result<ProfilePage, APIError>) -> Void) {
        loadCallCount += 1
        if let loadPage { completion(.success(loadPage)) }
    }
    func logout(completion: @escaping (Result<Void, APIError>) -> Void) {}
    func updateProfile(
        _ update: ProfileUpdate,
        completion: @escaping (Result<UserProfile, APIError>) -> Void
    ) {
        lastUpdate = update
    }
}
