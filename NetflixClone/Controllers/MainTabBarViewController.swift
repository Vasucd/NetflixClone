import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = UIColor.systemRed
        tabBar.barTintColor = UIColor.black
        tabBar.isTranslucent = false
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupViewControllers() {
        // Create view controllers safely
        let homeVC = createNavigationController(
            rootViewController: HomeViewController(),
            title: "Home",
            imageName: "house"
        )
        
        let searchVC = createNavigationController(
            rootViewController: SearchViewController(),
            title: "Search",
            imageName: "magnifyingglass"
        )
        
        let downloadsVC = createNavigationController(
            rootViewController: DownloadsViewController(),
            title: "Downloads",
            imageName: "arrow.down.to.line"
        )
        
        // Set view controllers
        viewControllers = [homeVC, searchVC, downloadsVC]
    }
    
    private func createNavigationController(rootViewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.title = title
        
        // Safe image loading
        if #available(iOS 13.0, *) {
            navigationController.tabBarItem.image = UIImage(systemName: imageName)
        } else {
            // Fallback for older iOS versions
            navigationController.tabBarItem.image = UIImage(named: imageName)
        }
        
        // Configure navigation bar
        navigationController.navigationBar.barTintColor = UIColor.black
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.isTranslucent = false
        
        return navigationController
    }
}