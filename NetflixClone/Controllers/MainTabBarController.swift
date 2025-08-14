//
//  MainTabBarController.swift
//  NetflixClone
//
//  Created by Developer on 2024/01/01.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // Strong references to prevent deallocation
    private var homeVC: HomeViewController!
    private var searchVC: SearchViewController!
    private var downloadsVC: DownloadsViewController!
    private var profileVC: ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
        delegate = self
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .gray
        tabBar.isTranslucent = false
        
        // Ensure tab bar appearance
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupViewControllers() {
        // Initialize view controllers with strong references
        homeVC = HomeViewController()
        searchVC = SearchViewController()
        downloadsVC = DownloadsViewController()
        profileVC = ProfileViewController()
        
        // Create navigation controllers
        let homeNavController = createNavController(
            rootViewController: homeVC,
            title: "Home",
            imageName: "house"
        )
        
        let searchNavController = createNavController(
            rootViewController: searchVC,
            title: "Search",
            imageName: "magnifyingglass"
        )
        
        let downloadsNavController = createNavController(
            rootViewController: downloadsVC,
            title: "Downloads",
            imageName: "arrow.down.to.line"
        )
        
        let profileNavController = createNavController(
            rootViewController: profileVC,
            title: "Profile",
            imageName: "person"
        )
        
        // Set view controllers
        viewControllers = [
            homeNavController,
            searchNavController,
            downloadsNavController,
            profileNavController
        ]
    }
    
    private func createNavController(rootViewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: imageName)
        navController.navigationBar.prefersLargeTitles = true
        navController.navigationBar.tintColor = .white
        
        // Configure navigation bar appearance
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        return navController
    }
    
    deinit {
        delegate = nil
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Prevent crashes by ensuring view controller is valid
        guard viewControllers?.contains(viewController) == true else {
            return false
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Handle tab selection safely
        guard let navController = viewController as? UINavigationController,
              let rootVC = navController.viewControllers.first else {
            return
        }
        
        // Refresh content when tab is selected
        if let refreshable = rootVC as? RefreshableViewController {
            refreshable.refreshContent()
        }
    }
}