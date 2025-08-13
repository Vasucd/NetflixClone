import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        let upcomingVC = UINavigationController(rootViewController: UpcomingViewController())
        let downloadVC = UINavigationController(rootViewController: DownloadViewController())
        
        // Configure tab bar items with icons
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
        
        setViewControllers([homeVC, searchVC, upcomingVC, downloadVC], animated: false)
    }
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black
        tabBar.isTranslucent = false
        
        // Ensure icons are visible
        tabBar.itemPositioning = .automatic
        tabBar.itemWidth = 0
        tabBar.itemSpacing = 0
    }
}