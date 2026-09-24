//
//  ProfileViewModel.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 09.09.2026.
//

import Foundation

@MainActor
final class ProfileViewModel {
    
    struct State {
        let profile: ProfileDisplayModel?
        let isLoading: Bool
        let errorMessage: String?
    }
    
    private let profileRepository: ProfileRepositoryProtocol
    private(set) var state = State(profile: nil, isLoading: false, errorMessage: nil)
    
    var onStateChange: ((State) -> Void)?
    var onLogout: (() -> Void)?
    
    init (profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    func loadProfile() {
        update(isLoading: true, errorMessage: nil)
        
        profileRepository.loadProfile { [weak self] result in
            Task { @MainActor in
                
                switch result {
                case let .success(page):
                    self?.update(
                        profile: Self.makeDisplayModel(from: page),
                        isLoading: false,
                        errorMessage: nil
                    )
                case let .failure(error):
                    self?.update(
                        isLoading: false,
                        errorMessage: error.userMessage
                    )
                }
                
            }
        }
    }
    
    func logout() {
        update(
            isLoading: true,
            errorMessage: nil
        )
        
        profileRepository.logout { [weak self] result in
            Task { @MainActor in
                
                switch result {
                    
                case .success:
                    self?.onLogout?()
                    
                case let .failure(error):
                    self?.update(
                        isLoading: false,
                        errorMessage: error.userMessage
                    )
                }
            }
        }
    }
    
    private func update(
        profile: ProfileDisplayModel? = nil,
        isLoading: Bool? = nil,
        errorMessage: String? = nil
    ) {
        state = State(
            profile: profile ?? state.profile,
            isLoading: isLoading ?? state.isLoading,
            errorMessage: errorMessage ?? state.errorMessage
        )
        onStateChange?(state)
    }
    
    private static func makeDisplayModel(from page: ProfilePage) -> ProfileDisplayModel {
        let profile = page.profile
        let taste = page.tasteProfile
        let fullName = [profile.firstName, profile.lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        return ProfileDisplayModel(
            initials: makeInitials(from: profile),
            displayName: fullName.isEmpty ? profile.displayName : fullName,
            username: "@\(profile.username)",
            email: profile.email,
            emailStatus: profile.emailVerified ? L10n.Profile.verified : L10n.Profile.notVerified,
            summary: taste.profileSummary,
            stats: [
                .init(title: L10n.Profile.Stats.completed, value: "\(taste.completedCount)"),
                .init(title: L10n.Profile.Stats.inProgress, value: "\(taste.inProgressCount)"),
                .init(title: L10n.Profile.Stats.hidden, value: "\(taste.hiddenCount)")
            ],
            sections: [
                .init(title: L10n.Profile.Section.genres, items: taste.favoriteGenres),
                .init(title: L10n.Profile.Section.themes, items: taste.favoriteThemes),
                .init(title: L10n.Profile.Section.atmospheres, items: taste.favoriteAtmospheres),
                .init(title: L10n.Profile.Section.settings, items: taste.favoriteSettings),
                .init(title: L10n.Profile.Section.disliked, items: taste.dislikedElements)
            ]
        )
        
    }
    
    private static func makeInitials(from profile: UserProfile) -> String {
        let source = [profile.firstName, profile.lastName].filter { !$0.isEmpty }
        let initials = source.compactMap(\.first).map(String.init).joined()
        return initials.isEmpty ? String(profile.username.prefix(1)).uppercased() : initials.uppercased()
    }
}
