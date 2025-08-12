import UIKit
import AppMetricaCore

// MARK: - AppDelegate
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - UIApplicationDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = coreDataStack.viewContext
   
        if let configuration = AppMetricaConfiguration(apiKey: AnalyticsConstants.appMetricaAPIKey) {
            AppMetrica.activate(with: configuration)
        }
            
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
    }
}
