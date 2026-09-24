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
        let profileNavigationController = UINavigationController()
        
        let searchCoordinator = SearchCoordinator(
            navigationController: searchNavigationController,
            container: container,
            username: username)
        
        let profileCoordinator = ProfileCoordinator(
            navigationController: profileNavigationController,
            container: container)
        
        profileCoordinator.onLogout = { [weak self] in
            self?.onLogout?()
        }
        
        self.searchCoordinator = searchCoordinator
        self.profileCoordinator = profileCoordinator
        
        searchCoordinator.start()
        profileCoordinator.start()
        
        searchNavigationController.tabBarItem = UITabBarItem(
            title: L10n.Tab.search,
            image: UIImage(systemName: "sparkles"),
            selectedImage: UIImage(systemName: "sparkles")
            )
        
        profileNavigationController.tabBarItem = UITabBarItem(
            title: L10n.Tab.profile,
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        
        tabBarController.viewControllers = [
            searchNavigationController,
            profileNavigationController
        ]
        
        navigationController.setViewControllers([tabBarController], animated: true)
            
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppTheme.Color.background
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = AppTheme.Color.primary
        tabBarController.tabBar.unselectedItemTintColor = AppTheme.Color.textSecondary
    }
    
}
