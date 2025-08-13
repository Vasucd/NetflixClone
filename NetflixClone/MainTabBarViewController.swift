import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .label
        tabBar.backgroundColor = .systemBackground
        tabBar.isTranslucent = false
    }
    
    private func setupViewControllers() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        let upcomingVC = UINavigationController(rootViewController: UpcomingViewController())
        let downloadVC = UINavigationController(rootViewController: DownloadViewController())
        
        // Configure tab bar items with system images
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        searchVC.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        
        upcomingVC.tabBarItem = UITabBarItem(
            title: "Coming Soon",
            image: UIImage(systemName: "play.circle"),
            selectedImage: UIImage(systemName: "play.circle.fill")
        )
        
        downloadVC.tabBarItem = UITabBarItem(
            title: "Downloads",
            image: UIImage(systemName: "arrow.down.to.line"),
            selectedImage: UIImage(systemName: "arrow.down.to.line.compact")
        )
        
        // Set navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        homeVC.navigationBar.standardAppearance = appearance
        searchVC.navigationBar.standardAppearance = appearance
        upcomingVC.navigationBar.standardAppearance = appearance
        downloadVC.navigationBar.standardAppearance = appearance
        
        homeVC.navigationBar.scrollEdgeAppearance = appearance
        searchVC.navigationBar.scrollEdgeAppearance = appearance
        upcomingVC.navigationBar.scrollEdgeAppearance = appearance
        downloadVC.navigationBar.scrollEdgeAppearance = appearance
        
        setViewControllers([homeVC, searchVC, upcomingVC, downloadVC], animated: false)
    }
}