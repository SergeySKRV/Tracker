import UIKit
import AppMetricaCore

// MARK: - TabBarController
final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        configureViewControllers()
        addTopBorder()

        let openEvent = [
            "event": "open",
            "screen": "TabBar"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: openEvent)
        print("Analytics: \(openEvent)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let closeEvent = [
            "event": "close",
            "screen": "TabBar"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: closeEvent)
        print("Analytics: \(closeEvent)")
    }
    
    // MARK: - Private Methods
    private func setupAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .ypWhiteDayNight
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .ypBlue
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    private func configureViewControllers() {
        let trackersViewModel = TrackersViewModel()
        let trackersViewController = TrackersViewController(viewModel: trackersViewModel)
        trackersViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Трекеры", comment: ""),
            image: UIImage(resource: .trackers),
            selectedImage: nil
        )
        let statisticsViewModel = StatisticsViewModel()
        let statisticsViewController = StatisticsViewController(viewModel: statisticsViewModel)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Статистика", comment: ""),
            image: UIImage(resource: .stats),
            selectedImage: nil
        )
        
        viewControllers = [trackersViewController, statisticsViewController]
   
        self.delegate = self
    }
    
    private func addTopBorder() {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.ypGray.cgColor
        borderLayer.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        tabBar.layer.addSublayer(borderLayer)
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        let selectedItem = tabBarController.selectedIndex
        let tabName = selectedItem == 0 ? "trackers" : "statistics"
        
        let tabEvent = [
            "event": "click",
            "screen": "TabBar",
            "item": tabName
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: tabEvent)
        print("Analytics: \(tabEvent)")
    }
}
