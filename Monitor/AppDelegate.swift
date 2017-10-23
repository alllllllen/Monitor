//
//  AppDelegate.swift
//  Monitor
//
//  Created by Allen on 2017/9/25.
//  Copyright © 2017年 Allen. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import UserNotifications
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    @objc let beaconManager = ESTBeaconManager()
    @objc var ref: DatabaseReference!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        self.beaconManager.delegate = self
        self.ref = Database.database().reference()
        self.beaconManager.requestAlwaysAuthorization()
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
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19140")!, major: 58531, minor: 3, identifier: "Table3"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "D0D3FA86-CA76-45EC-9BD9-6AF4F6B19140")!, major: 58531, minor: 2, identifier: "Table2"))
        self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5582, minor: 1, identifier: "Table1(Location Beacon)"))
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: .alert, categories: nil))
        return true
    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        self.ref.child("/table/\(region.minor!)/taken").setValue(1)
        if let user = Auth.auth().currentUser {
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
        self.ref.child("/table/\(region.minor!)/taken").setValue(0)
        if let user = Auth.auth().currentUser {
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

