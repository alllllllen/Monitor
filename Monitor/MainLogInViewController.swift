//
//  MainViewController.swift
//  Monitor
//
//  Created by Allen on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

import UIKit


import Firebase
import GoogleSignIn
import FBSDKLoginKit



class MainLogInViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var describe: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.describe.text = "親愛的顧客您好\n為了提供更好的用戶體驗\n本APP提供了基於藍牙技術的定位系統，讓顧客可以經由網站得知店內座位狀況\n以下登入請使用咖啡館官網帳號、Google或Facebook登入"
    }
    
    enum AuthProvider {
        case authEmail
        case authFacebook
        case authGoogle
    }
    
    func showAuthPicker(_ providers: [AuthProvider]) {
        let picker = UIAlertController(title: "登入方式", message: nil, preferredStyle: .alert)
        for provider in providers {
            var action: UIAlertAction
            switch provider {
            case .authEmail:
                action = UIAlertAction(title: "Email", style: .default) { (UIAlertAction) in
                    self.performSegue(withIdentifier: "email", sender:nil)
                }
            case .authFacebook:
                action = UIAlertAction(title: "Facebook", style: .default) { (UIAlertAction) in
                    let loginManager = FBSDKLoginManager()
                    loginManager.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
                        if let error = error {
                            self.showMessagePrompt(error.localizedDescription)
                        } else if result!.isCancelled {
                            print("FBLogin cancelled")
                        }
                        else {
                            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                            Auth.auth().signIn(with: credential, completion: { (user, error) in
                                let alertController = UIAlertController(title: "登入資訊", message: "經由Facebook登入成功", preferredStyle: .alert)
                                let defaultAction = UIKit.UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                                    self.performSegue(withIdentifier: "facebook", sender: nil)
                                })
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                            })
                        }
                    })
                }
            case .authGoogle:
                action = UIAlertAction(title: "Google", style: .default) { (UIAlertAction) in
                    GIDSignIn.sharedInstance().uiDelegate = self
                    GIDSignIn.sharedInstance().signIn()
                }
            }
            picker.addAction(action)
        }
        picker.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func didTapSignIn(_ sender: Any) {
        showAuthPicker([
            AuthProvider.authEmail,
            AuthProvider.authGoogle,
            AuthProvider.authFacebook,
            ])
    }

}
