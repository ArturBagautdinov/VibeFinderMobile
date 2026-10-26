//
//  MainTabBarCoordinator.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 11.09.2026.
//

import UIKit
import Swinject

final class MainTabBarCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private let container: Container
    private var username: String
    
    private let tabBarController = UITabBarController()
    private var searchCoordinator: SearchCoordinator?
    private var favoritesCoordinator: FavoritesCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    
    var onLogout: (() -> Void)?
    
    init (
        navigationController: UINavigationController,
        container: Container,
        username: String
    ) {
        self.navigationController = navigationController
        self.container = container
        self.username = username
    }
    
    func start() {
        configureTabBar()
        
        let searchNavigationController = UINavigationController()
        let favoritesNavigationController = UINavigationController()
        let profileNavigationController = UINavigationController()
        
        let searchCoordinator = SearchCoordinator(
            navigationController: searchNavigationController,
            container: container,
            username: username)
        
        let profileCoordinator = ProfileCoordinator(
            navigationController: profileNavigationController,
            container: container)

        let favoritesCoordinator = FavoritesCoordinator(
            navigationController: favoritesNavigationController,
            container: container)
        
        profileCoordinator.onLogout = { [weak self] in
            self?.onLogout?()
        }
        profileCoordinator.onAppearanceChanged = { [weak self] avatar, initials in
            self?.searchCoordinator?.updateProfileAppearance(avatar: avatar, initials: initials)
        }
        
        self.searchCoordinator = searchCoordinator
        self.favoritesCoordinator = favoritesCoordinator
        self.profileCoordinator = profileCoordinator
        
        searchCoordinator.start()
        favoritesCoordinator.start()
        profileCoordinator.start()
        
        searchNavigationController.tabBarItem = UITabBarItem(
            title: L10n.Tab.search,
            image: UIImage(systemName: "sparkles"),
            selectedImage: UIImage(systemName: "sparkles")
            )

        favoritesNavigationController.tabBarItem = UITabBarItem(
            title: L10n.Tab.favorites,
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        
        profileNavigationController.tabBarItem = UITabBarItem(
            title: L10n.Tab.profile,
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        
        tabBarController.viewControllers = [
            searchNavigationController,
            favoritesNavigationController,
            profileNavigationController
        ]
        
        navigationController.setViewControllers([tabBarController], animated: true)
            
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.backgroundColor = .clear
        tabBarController.tabBar.isTranslucent = true
        tabBarController.tabBar.tintColor = AppTheme.Color.primary
        tabBarController.tabBar.unselectedItemTintColor = AppTheme.Color.textSecondary
    }
    
}
