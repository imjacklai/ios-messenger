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
import SVProgressHUD

class MessageListController: UIViewController {
    
    fileprivate var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Chat"
        
        guard let uid = Auth.auth().currentUser?.uid else {
            // User not sign in.
            self.presentSignInController()
            return
        }
        
        fetchUser(uid: uid)
    }
    
    fileprivate func fetchUser(uid: String) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: String] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            self.user = user
            
            let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            profileImageView.kf.setImage(with: user.profileImageUrl, placeholder: #imageLiteral(resourceName: "profile"))
            profileImageView.layer.cornerRadius = 12
            profileImageView.layer.masksToBounds = true
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentProfileController)))
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        })
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

}

extension MessageListController: SignInControllerDelegate {
    
    func alreadySignIn(uid: String) {
        fetchUser(uid: uid)
    }
    
}

extension MessageListController: ProfileControllerDelegate {
    
    func alreadySignOut() {
        presentSignInController()
    }
    
}
