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

class MessageListController: UITableViewController {
    
    fileprivate let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    fileprivate let indicator = UIActivityIndicatorView()
    
    fileprivate var user: User?
    fileprivate var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewMessage))
        
        profileImageView.layer.cornerRadius = 12
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentProfileController)))
        
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.rowHeight = 72
        tableView.addSubview(indicator)
        
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(tableView)
        }
        
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
        
        fetchSelf(uid: uid)
        fetchUserMessages(uid: uid)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentChatController(user: users[indexPath.row])
    }
    
    fileprivate func fetchSelf(uid: String) {
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: String] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            self.user = user
            self.profileImageView.kf.setImage(with: user.profileImageUrl, placeholder: #imageLiteral(resourceName: "profile"))
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.profileImageView)
        })
    }
    
    fileprivate func fetchUserMessages(uid: String) {
        indicator.startAnimating()
        Database.database().reference().child("user-list").child(uid).observe(.childAdded, with: { (snapshot) in
            let partnerId = snapshot.key
            Database.database().reference().child("user-list").child(uid).child(partnerId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    let message = Message(dictionary: dictionary)
                    self.fetchPartner(message: message)
                })
            })
        })
    }
    
    fileprivate func fetchPartner(message: Message) {
        guard let partnerId = message.chatPartner() else { return }
        
        Database.database().reference().child("users").child(partnerId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: String] else { return }
            let user = User(uid: snapshot.key, dictionary: dictionary)
            user.timestamp = message.timestamp
            
            if message.imageUrl != nil {
                if message.fromId == Auth.auth().currentUser?.uid {
                    user.lastMessage = "你傳送一張圖片"
                } else {
                    user.lastMessage = "對方傳送一張圖片"
                }
            } else {
                user.lastMessage = message.text
            }
            
            self.users.filter { it -> Bool in it.uid == user.uid }.forEach { it in self.users.remove(at: self.users.index(of: it)!) }
            self.users.append(user)
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.tableView.reloadData()
            }
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
    
    fileprivate func presentChatController(user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
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
        fetchSelf(uid: uid)
    }
    
}

extension MessageListController: ProfileControllerDelegate {
    
    func performSignOut() {
        signOut()
    }
    
}

extension MessageListController: NewMessageControllerDelegate {
    
    func chatWith(user: User) {
        presentChatController(user: user)
    }
    
}
