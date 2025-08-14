import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Initialize main tab bar controller safely
        let mainTabBarController = MainTabBarViewController()
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
        
        // Configure appearance
        configureAppearance()
        
        // Initialize services safely
        NetworkManager.shared.configure()
        
        return true
    }
    
    private func configureAppearance() {
        // Safe appearance configuration
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UITabBar.appearance().barTintColor = UIColor.black
            UITabBar.appearance().tintColor = UIColor.red
        }
        
        // Navigation bar appearance
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    // MARK: UISceneSession Lifecycle (iOS 13+)
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}