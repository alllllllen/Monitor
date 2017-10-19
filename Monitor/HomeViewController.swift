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
            last.photoURL = photoURL;  // to prevent earlier image overwrites later one.
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
                self.userimg.image = UIImage.init(named: "avatar")
            }
            
        }
        else {
            self.performSegue(withIdentifier: "unlogin", sender: nil)
        }
        
    }
    
    @IBAction func didTapSignOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
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
