import UIKit

// MARK: - TabBarController Class
final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        configureViewControllers()
    }
    
    // MARK: - Appearance Setup
    
    private func setupAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .ypWhiteDay
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .ypBlue
        tabBar.standardAppearance = tabBarAppearance
    }
    
    // MARK: - View Controllers Configuration
    
    private func configureViewControllers() {
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackers),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .stats),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersViewController, statisticsViewController]
    }
}
