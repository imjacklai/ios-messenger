//
//  SignInController.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SVProgressHUD
import UIColor_Hex_Swift

protocol SignInControllerDelegate {
    func alreadySignIn(uid: String)
}

class SignInController: UIViewController {
    
    let signInRegisterView = SignInRegisterView(color: UIColor("#009688"))
    let googleSignInButton = UIButton(type: .system)
    let indicator = UIActivityIndicatorView()
    let googleSignIn = GIDSignIn.sharedInstance()
    
    var delegate: SignInControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInRegisterView.delegate = self
        
        googleSignIn?.delegate = self
        googleSignIn?.uiDelegate = self
        
        googleSignInButton.setTitle("Google 登入", for: .normal)
        googleSignInButton.setTitleColor(.white, for: .normal)
        googleSignInButton.backgroundColor = UIColor("#DD4B39")
        googleSignInButton.layer.cornerRadius = 5
        googleSignInButton.layer.masksToBounds = true
        googleSignInButton.addTarget(self, action: #selector(signInViaGoogle), for: .touchUpInside)
        
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        
        let orLabel = UILabel()
        orLabel.text = "- 或 -"
        orLabel.textColor = .gray
        orLabel.font = UIFont.systemFont(ofSize: 14)
        
        let contentView = UIView()
        contentView.addSubview(signInRegisterView)
        contentView.addSubview(orLabel)
        contentView.addSubview(googleSignInButton)
        
        view.backgroundColor = .white
        view.addSubview(contentView)
        view.addSubview(indicator)
        
        contentView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(signInRegisterView)
            make.bottom.equalTo(googleSignInButton)
            make.center.equalTo(view)
        }
        
        signInRegisterView.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentView)
        }
        
        orLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signInRegisterView.snp.bottom).offset(30)
            make.centerX.equalTo(contentView)
        }
        
        googleSignInButton.snp.makeConstraints { (make) in
            make.width.equalTo(signInRegisterView)
            make.height.equalTo(40)
            make.top.equalTo(orLabel.snp.bottom).offset(30)
            make.centerX.equalTo(contentView)
        }
        
        indicator.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(contentView.snp.bottom).offset(20)
        }
    }
    
    @objc fileprivate func signInViaGoogle() {
        googleSignIn?.signIn()
        indicator.startAnimating()
    }
    
    fileprivate func writeUserToDatebase(uid: String, values: [String:String]) {
        Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                self.indicator.stopAnimating()
                SVProgressHUD.showError(withStatus: "登入失敗")
                print("Failed to write user to database: ", error)
                return
            }
            
            self.delegate?.alreadySignIn(uid: uid)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}

extension SignInController: SignInRegisterViewDelegate {
    
    func signIn(email: String, password: String) {
        indicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.indicator.stopAnimating()
                SVProgressHUD.showError(withStatus: "信箱或密碼不符")
                print("Failed to sign in: ", error)
                return
            }
            
            guard let uid = user?.uid else {
                self.indicator.stopAnimating()
                print("Failed to get uid")
                return
            }
            
            self.delegate?.alreadySignIn(uid: uid)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func register(name: String, email: String, password: String) {
        indicator.startAnimating()
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.indicator.stopAnimating()
                SVProgressHUD.showError(withStatus: "註冊失敗")
                print("Failed to register: ", error)
                return
            }
            
            guard let uid = user?.uid else {
                self.indicator.stopAnimating()
                print("Failed to get uid")
                return
            }
            
            let values = ["name": name, "email": email]
            self.writeUserToDatebase(uid: uid, values: values)
        }
    }
    
}

extension SignInController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor googleUser: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.indicator.stopAnimating()
            if error.localizedDescription != "The user canceled the sign-in flow." {
                SVProgressHUD.showError(withStatus: "登入失敗")
                print("Failed to sign in via Google: ", error)
            }
            return
        }
        
        guard let authentication = googleUser.authentication else {
            self.indicator.stopAnimating()
            SVProgressHUD.showError(withStatus: "登入失敗")
            print("Failed to authenticate via Google")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                self.indicator.stopAnimating()
                SVProgressHUD.showError(withStatus: "登入失敗")
                print("Credential error: ", error)
                return
            }
            
            guard let uid = user?.uid, let name = googleUser.profile.name, let email = googleUser.profile.email, let profileImageUrl = googleUser.profile.imageURL(withDimension: 300) else {
                self.indicator.stopAnimating()
                SVProgressHUD.showError(withStatus: "登入失敗")
                print("Failed to get uid or name or email")
                return
            }
            
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(uid) {
                    let values = ["name": name, "email": email]
                    self.writeUserToDatebase(uid: uid, values: values)
                } else {
                    let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl.absoluteString]
                    self.writeUserToDatebase(uid: uid, values: values)
                }
            })
        })
    }
    
}

extension SignInController: GIDSignInUIDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if let error = error {
            print("Dispatch error: ", error)
            return
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
}
