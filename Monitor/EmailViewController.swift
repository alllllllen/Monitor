//
//  EmailViewController.swift
//  Monitor
//
//  Created by Allen on 2017/10/16.
//  Copyright © 2017年 Allen. All rights reserved.
//

import UIKit
import Firebase

class EmailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.email.delegate = self
        self.password.delegate = self
    }
    
    @IBAction func didTapLogIn(_ sender: Any) {
        if let email = self.email.text, let pw = self.password.text {
            Auth.auth().signIn(withEmail: email, password: pw){ (user, error) in
                if let error = error {
                    let alertController = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                let alertController = UIAlertController(title: "登入資訊", message: "經由Email登入成功", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                    self.performSegue(withIdentifier: "emaillogin", sender: nil)
                })
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
