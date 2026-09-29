import Foundation

@MainActor
final class EditProfileViewModel {
    struct State {
        var original: UserProfile
        var draft: EditProfileDraft
        var isSaving = false
        var errorMessage: String?

        var isDirty: Bool {
            Self.trimmed(draft.firstName) != original.firstName ||
            Self.trimmed(draft.lastName) != original.lastName ||
            draft.avatar != original.avatar
        }

        var canSave: Bool {
            !isSaving && isDirty &&
            Self.valid(draft.firstName) && Self.valid(draft.lastName)
        }

        var initials: String {
            let value = [draft.firstName, draft.lastName]
                .compactMap { Self.trimmed($0).first }
                .map(String.init)
                .joined()
            return value.isEmpty ? String(original.username.prefix(1)).uppercased() : value.uppercased()
        }

        private static func trimmed(_ value: String) -> String {
            value.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        private static func valid(_ value: String) -> Bool {
            (2...80).contains(trimmed(value).count)
        }
    }

    private let repository: ProfileRepositoryProtocol
    private let analyticsTracker: AnalyticsTrackerProtocol
    private(set) var state: State
    var onStateChange: ((State) -> Void)?
    var onSaved: ((UserProfile) -> Void)?

    init(
        profile: UserProfile,
        repository: ProfileRepositoryProtocol,
        analyticsTracker: AnalyticsTrackerProtocol
    ) {
        self.repository = repository
        self.analyticsTracker = analyticsTracker
        state = State(original: profile, draft: EditProfileDraft(profile: profile))
    }

    func setNames(firstName: String, lastName: String) {
        state.draft.firstName = firstName
        state.draft.lastName = lastName
        state.errorMessage = nil
        publish()
    }

    func selectStyle(_ style: ProfileAvatarStyle) {
        switch style {
        case .symbol:
            state.draft.avatar = ProfileAvatar(
                style: .symbol,
                symbol: state.draft.selectedSymbol,
                backgroundHex: state.draft.selectedColor,
                foregroundHex: state.original.avatar?.style == .symbol
                    ? (state.original.avatar?.foregroundHex ?? "#FFFFFF") : "#FFFFFF"
            )
        case .color:
            state.draft.avatar = ProfileAvatar(
                style: .color,
                symbol: nil,
                backgroundHex: state.draft.selectedColor,
                foregroundHex: nil
            )
        case .none:
            state.draft.avatar = nil
        }
        state.errorMessage = nil
        publish()
    }

    func selectSymbol(_ symbol: String) {
        state.draft.selectedSymbol = symbol
        selectStyle(.symbol)
    }

    func selectColor(_ color: String) {
        state.draft.selectedColor = color
        selectStyle(state.draft.avatar?.style == .color ? .color : .symbol)
    }

    func save() {
        guard !state.isSaving else { return }
        let firstName = state.draft.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = state.draft.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !firstName.isEmpty, !lastName.isEmpty else {
            state.errorMessage = L10n.Profile.Edit.validationRequired
            publish()
            return
        }
        guard (2...80).contains(firstName.count), (2...80).contains(lastName.count) else {
            state.errorMessage = L10n.Profile.Edit.validationLength
            publish()
            return
        }
        guard state.isDirty else { return }

        let change: ProfileAvatarChange
        if state.draft.avatar == state.original.avatar {
            change = .unchanged
        } else if let avatar = state.draft.avatar {
            change = .set(avatar)
        } else {
            change = .clear
        }
        
        analyticsTracker.track(
            ProfileEditAnalyticsEvent.saveRequested(
                firstNameChanged: firstName != state.original.firstName,
                lastNameChanged: lastName != state.original.lastName,
                avatarChange: change,
                avatarStyle: state.draft.avatar?.style ?? .none
            )
        )
        
        state.isSaving = true
        state.errorMessage = nil
        publish()

        repository.updateProfile(
            ProfileUpdate(firstName: firstName, lastName: lastName, avatarChange: change)
        ) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.state.isSaving = false
                switch result {
                case let .success(profile):
                    self.analyticsTracker.track(ProfileEditAnalyticsEvent.saveSucceeded())
                    self.state.original = profile
                    self.state.draft = EditProfileDraft(profile: profile)
                    self.publish()
                    self.onSaved?(profile)
                case let .failure(error):
                    self.analyticsTracker.track(
                        ProfileEditAnalyticsEvent.saveFailed(error: error)
                    )
                    self.state.errorMessage = error.userMessage
                    self.publish()
                }
            }
        }
    }

    private func publish() {
        onStateChange?(state)
    }
}
