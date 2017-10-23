//
//  HomeViewController.swift
//  Monitor
//
//  Created by Allen on 2017/10/18.
//  Copyright © 2017年 Allen. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class HomeViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userimg: UIImageView!
    @IBOutlet weak var homeDescribe: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            self.username.adjustsFontSizeToFitWidth = true
            if let u = user.displayName {
                self.username.text = u
            }
            else {
                self.username.text = "使用者"
            }
            let photoURL = user.photoURL
            struct last {
                static var photoURL: URL? = nil
            }
            last.photoURL = photoURL;
            if let photoURL = photoURL {
                DispatchQueue.global(qos: .default).async {
                    let data = try? Data.init(contentsOf: photoURL)
                    if let data = data {
                        let image = UIImage.init(data: data)
                        DispatchQueue.main.async(execute: {
                            if photoURL == last.photoURL {
                                self.userimg.image = image
                            }
                        })
                    }
                }
            }
            else {
                self.userimg.image = UIImage.init(named: "user.jpg")
            }
        }
    }
    
    @IBAction func didTapSignOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        let fbLogOut = FBSDKLoginManager()
        fbLogOut.logOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let alertController = UIAlertController(title: "登出資訊", message: "登出成功", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {(UIAlertAction) in
                self.performSegue(withIdentifier: "didlogout", sender: nil)
                })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out\n\(signOutError)")
        }
    }
}
