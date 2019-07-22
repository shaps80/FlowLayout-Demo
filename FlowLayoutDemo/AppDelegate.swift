import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /*
     
     It appears animating the insert/delete of a supplementary view that is not associated with a dataSource update is not supported.
     However resizing the view is.
     
     Although not ideal one solution to showing and hiding a global element would be to return .leastNormalMagnitude for the height
     when you want it collapsed.
     
     This should work assuming your constraints are not conflicting and that you're not using:
     
     .pinsToBounds && .pinsToContent
     
     in conjunction with one another.
     
     */


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.backgroundColor = .white
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}
