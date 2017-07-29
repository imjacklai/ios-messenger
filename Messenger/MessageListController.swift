//
//  MessageListController.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SVProgressHUD

class MessageListController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Messenger"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "登出", style: .plain, target: self, action: #selector(confirmSignOut))
        checkUserSignIn()
    }
    
    fileprivate func checkUserSignIn() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.presentSignInController()
            return
        }
        
        print(uid)
    }
    
    fileprivate func presentSignInController() {
        let signInController = SignInController()
        signInController.delegate = self
        present(signInController, animated: true, completion: nil)
    }
    
    fileprivate func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            SVProgressHUD.showError(withStatus: "登出失敗")
            print("Failed to sign out: ", error)
            return
        }
        
        presentSignInController()
    }
    
    @objc fileprivate func confirmSignOut() {
        let alertController = UIAlertController(title: "確定要登出？", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "登出", style: .default) { (action) in
            self.signOut()
            GIDSignIn.sharedInstance().signOut()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }

}

extension MessageListController: SignInControllerDelegate {
    
    func alreadySignIn(uid: String) {
        print(uid)
    }
    
}
