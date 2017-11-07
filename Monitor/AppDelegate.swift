import UIKit
import Firebase
import GoogleSignIn
import UserNotifications
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let beaconManager = ESTBeaconManager()
    var ref: DatabaseReference!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        self.ref = Database.database().reference()
        if Auth.auth().currentUser != nil {
            self.window?.rootViewController?.performSegue(withIdentifier: "login", sender: nil)
        }
        else {
            self.window?.rootViewController?.performSegue(withIdentifier: "unlogin", sender: nil)
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            application.registerForRemoteNotifications()
        }
//        self.beaconManager.stopMonitoringForAllRegions()

        
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 1, minor: 4, identifier: "Table1"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 2, minor: 2, identifier: "Table2"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 3, minor: 2, identifier: "Table3"))

        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 4, minor: 2, identifier: "Table4"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 5, minor: 2, identifier: "Table5"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 6, minor: 2, identifier: "Table6"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 7, minor: 2, identifier: "Table7"))

        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 8, minor: 2, identifier: "Table8"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 9, minor: 2, identifier: "Table9"))

        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 10, minor: 2, identifier: "Table10"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 11, minor: 2, identifier: "Table11"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 12, minor: 2, identifier: "Table12"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 13, minor: 2, identifier: "Table13"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19149")!, major: 14, minor: 2, identifier: "Table14"))
        print(self.beaconManager.monitoredRegions)

        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: .alert, categories: nil))
        return true
    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        self.ref.child("/table/\(region.major!)/taken").setValue(1)
        if let user = Auth.auth().currentUser {
            self.ref.child("/users/\(user.uid)/table").setValue("\(region.identifier)")
            let notification = UILocalNotification()
            notification.alertBody =
            "歡迎光臨,\(user.displayName!)先生/小姐\n您正坐在\(region.identifier)"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
        else {
            let notification = UILocalNotification()
            notification.alertBody =
            "歡迎光臨,您正坐在\(region.identifier)"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        self.ref.child("/table/\(region.major!)/taken").setValue(0)
        if let user = Auth.auth().currentUser {
            self.ref.child("/users/\(user.uid)/table").setValue("null")
            let notification = UILocalNotification()
            notification.alertBody =
            "Goodbye,\(user.displayName!)先生/小姐\n期待您的再次光臨"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
        else {
            let notification = UILocalNotification()
            notification.alertBody =
            "Goodbye,期待您的再次光臨"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return self.application(application, open: url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard let controller = GIDSignIn.sharedInstance().uiDelegate as? MainLogInViewController else { return }
        if let error = error {
            controller.showMessagePrompt(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("\(error)")
                return
            }
            let alertController = UIAlertController(title: "登入資訊", message: "經由Google登入成功", preferredStyle: .alert)
            let defaultAction = UIKit.UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                self.window?.rootViewController!.performSegue(withIdentifier: "home", sender: nil)
            })
            alertController.addAction(defaultAction)
            controller.present(alertController, animated: true, completion: nil)
        }
    }
    
}
