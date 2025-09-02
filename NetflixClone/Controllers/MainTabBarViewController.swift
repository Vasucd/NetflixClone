//
//  MainTabBarViewController.swift
//  NetflixClone
//
//  Created by Developer on Date.
//  Copyright © 2023 NetflixClone. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .systemRed
        tabBar.backgroundColor = .systemBackground
        tabBar.isTranslucent = false
    }
    
    private func setupViewControllers() {
        let homeVC = HomeViewController()
        let searchVC = SearchViewController()
        let comingSoonVC = ComingSoonViewController()
        let downloadsVC = DownloadsViewController()
        let moreVC = MoreViewController()
        
        // Setup Navigation Controllers
        let homeNavController = UINavigationController(rootViewController: homeVC)
        let searchNavController = UINavigationController(rootViewController: searchVC)
        let comingSoonNavController = UINavigationController(rootViewController: comingSoonVC)
        let downloadsNavController = UINavigationController(rootViewController: downloadsVC)
        let moreNavController = UINavigationController(rootViewController: moreVC)
        
        // Setup Tab Bar Items
        homeNavController.tabBarItem = UITabBarItem(
            title: "Mobile", // Updated from "Home" to "Mobile"
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        searchNavController.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        
        comingSoonNavController.tabBarItem = UITabBarItem(
            title: "Coming Soon",
            image: UIImage(systemName: "play.circle"),
            selectedImage: UIImage(systemName: "play.circle.fill")
        )
        
        downloadsNavController.tabBarItem = UITabBarItem(
            title: "Downloads",
            image: UIImage(systemName: "arrow.down.to.line"),
            selectedImage: UIImage(systemName: "arrow.down.to.line.fill")
        )
        
        moreNavController.tabBarItem = UITabBarItem(
            title: "More",
            image: UIImage(systemName: "line.3.horizontal"),
            selectedImage: UIImage(systemName: "line.3.horizontal")
        )
        
        // Set View Controllers
        viewControllers = [
            homeNavController,
            searchNavController,
            comingSoonNavController,
            downloadsNavController,
            moreNavController
        ]
    }
}