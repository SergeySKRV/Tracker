import UIKit

// MARK: - TabBarController
final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        configureViewControllers()
        addTopBorder()
    }
    
    // MARK: - Private Methods
    private func setupAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .ypWhiteDay
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .ypBlue
        tabBar.standardAppearance = tabBarAppearance
    }
    
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
        
        viewControllers = [trackersViewController, statisticsViewController]
    }
    
    private func addTopBorder() {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.ypGray.cgColor
        borderLayer.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        tabBar.layer.addSublayer(borderLayer)
    }
}
