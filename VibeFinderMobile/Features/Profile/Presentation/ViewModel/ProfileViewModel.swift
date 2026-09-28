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
    private var currentPage: ProfilePage?
    var editableProfile: UserProfile? { currentPage?.profile }
    
    var onStateChange: ((State) -> Void)?
    var onLogout: (() -> Void)?
    
    init (profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    func loadProfile() {
        state = State(profile: state.profile, isLoading: true, errorMessage: nil)
        onStateChange?(state)
        
        profileRepository.loadProfile { [weak self] result in
            Task { @MainActor in
                
                switch result {
                case let .success(page):
                    self?.currentPage = page
                    self?.setState(
                        profile: Self.makeDisplayModel(from: page),
                        isLoading: false,
                        errorMessage: nil
                    )
                case let .failure(error):
                    guard let self else { return }
                    self.setState(
                        profile: self.state.profile,
                        isLoading: false,
                        errorMessage: error.userMessage
                    )
                }
                
            }
        }
    }

    func applyUpdatedProfile(_ profile: UserProfile) {
        guard let currentPage else { return }
        let updatedPage = ProfilePage(profile: profile, tasteProfile: currentPage.tasteProfile)
        self.currentPage = updatedPage
        state = State(
            profile: Self.makeDisplayModel(from: updatedPage),
            isLoading: false,
            errorMessage: nil
        )
        onStateChange?(state)
    }

    func logout() {
        state = State(profile: state.profile, isLoading: true, errorMessage: nil)
        onStateChange?(state)
        
        profileRepository.logout { [weak self] result in
            Task { @MainActor in
                
                switch result {
                    
                case .success:
                    self?.onLogout?()
                    
                case let .failure(error):
                    guard let self else { return }
                    self.setState(
                        profile: self.state.profile,
                        isLoading: false,
                        errorMessage: error.userMessage
                    )
                }
            }
        }
    }
    
    private func setState(
        profile: ProfileDisplayModel?,
        isLoading: Bool,
        errorMessage: String?
    ) {
        state = State(profile: profile, isLoading: isLoading, errorMessage: errorMessage)
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
            avatar: profile.avatar,
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
