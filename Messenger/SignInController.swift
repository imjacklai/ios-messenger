//
//  SignInController.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import UIColor_Hex_Swift

protocol SignInControllerDelegate {
    func alreadySignIn(uid: String)
}

class SignInController: UIViewController {
    
    let signInRegisterView = SignInRegisterView(color: UIColor("#009688"))
    
    var delegate: SignInControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInRegisterView.delegate = self
        
        view.backgroundColor = .white
        view.addSubview(signInRegisterView)
        
        signInRegisterView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
}

extension SignInController: SignInRegisterViewDelegate {
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "信箱或密碼不符")
                print("Failed to sign in: ", error)
                return
            }
            
            guard let uid = user?.uid else {
                print("Failed to get uid")
                return
            }
            
            self.delegate?.alreadySignIn(uid: uid)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func register(name: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "註冊失敗")
                print("Failed to register: ", error)
                return
            }
            
            guard let uid = user?.uid else {
                print("Failed to get uid")
                return
            }
            
            let values = ["name": name, "email": email]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    print("Failed to write user to database: ", error)
                    return
                }
                
                self.delegate?.alreadySignIn(uid: uid)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
}
