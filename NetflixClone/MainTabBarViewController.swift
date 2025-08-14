import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🎬 MainTabBarViewController: viewDidLoad started")
        
        setupTabBar()
        
        print("🎬 MainTabBarViewController: viewDidLoad completed successfully")
    }
    
    private func setupTabBar() {
        print("🎬 MainTabBarViewController: Setting up tab bar controllers")
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        let upcomingVC = UINavigationController(rootViewController: UpcomingViewController())
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        let downloadVC = UINavigationController(rootViewController: DownloadViewController())
        
        homeVC.tabBarItem.image = UIImage(systemName: "house")
        homeVC.title = "Home"
        
        upcomingVC.tabBarItem.image = UIImage(systemName: "play.circle")
        upcomingVC.title = "Coming Soon"
        
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchVC.title = "Top Search"
        
        downloadVC.tabBarItem.image = UIImage(systemName: "arrow.down.to.line")
        downloadVC.title = "Downloads"
        
        tabBar.tintColor = .label
        
        setViewControllers([homeVC, upcomingVC, searchVC, downloadVC], animated: true)
        
        print("🎬 MainTabBarViewController: Tab bar setup completed with \(viewControllers?.count ?? 0) controllers")
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("🎬 MainTabBarViewController: Tab selected - \(item.title ?? "Unknown")")
    }
}