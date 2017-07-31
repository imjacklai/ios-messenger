//
//  MessageListController.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import GoogleSignIn
import SVProgressHUD

class MessageListController: UIViewController {
    
    fileprivate let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    
    fileprivate var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewMessage))
        
        profileImageView.layer.cornerRadius = 12
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentProfileController)))
        
        guard let uid = Auth.auth().currentUser?.uid else {
            // User not sign in.
            UserDefaults.standard.set(true, forKey: "not_first_run")
            self.presentSignInController()
            return
        }
        
        if !UserDefaults.standard.bool(forKey: "not_first_run") {
            UserDefaults.standard.set(true, forKey: "not_first_run")
            signOut()
        }
        
        fetchUser(uid: uid)
    }
    
    fileprivate func fetchUser(uid: String) {
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: String] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            self.user = user
            self.profileImageView.kf.setImage(with: user.profileImageUrl, placeholder: #imageLiteral(resourceName: "profile"))
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.profileImageView)
        })
    }
    
    fileprivate func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut()
        } catch {
            SVProgressHUD.showError(withStatus: "登出失敗")
            print("Failed to sign out: ", error)
            return
        }
        
        navigationController?.popViewController(animated: true)
        presentSignInController()
    }
    
    fileprivate func presentSignInController() {
        let signInController = SignInController()
        signInController.delegate = self
        present(signInController, animated: true, completion: nil)
    }
    
    @objc fileprivate func presentProfileController() {
        let profileController = ProfileController()
        profileController.delegate = self
        profileController.user = self.user
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    @objc fileprivate func createNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.delegate = self
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }

}

extension MessageListController: SignInControllerDelegate {
    
    func alreadySignIn(uid: String) {
        fetchUser(uid: uid)
    }
    
}

extension MessageListController: ProfileControllerDelegate {
    
    func performSignOut() {
        signOut()
    }
    
}

extension MessageListController: NewMessageControllerDelegate {
    
    func chatWith(user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
}
