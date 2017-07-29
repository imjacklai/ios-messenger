//
//  ProfileController.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SVProgressHUD

protocol ProfileControllerDelegate {
    func alreadySignOut()
}

class ProfileController: UIViewController {
    
    fileprivate let profileImageView = UIImageView()
    fileprivate let emailLabel = UILabel()
    
    var delegate: ProfileControllerDelegate?
    
    var user: User? {
        didSet { setupProfile() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 75
        profileImageView.layer.masksToBounds = true
        
        view.backgroundColor = .white
        view.addSubview(profileImageView)
        view.addSubview(emailLabel)
        
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(150)
            make.center.equalTo(view)
        }
        
        emailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(30)
            make.centerX.equalTo(view)
        }
    }
    
    fileprivate func setupProfile() {
        guard let user = user else { return }
        navigationItem.title = user.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登出", style: .plain, target: self, action: #selector(confirmSignOut))
        profileImageView.kf.setImage(with: user.profileImageUrl, placeholder: #imageLiteral(resourceName: "profile"))
        emailLabel.text = user.email
    }
    
    fileprivate func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            SVProgressHUD.showError(withStatus: "登出失敗")
            print("Failed to sign out: ", error)
            return
        }
        
        navigationController?.popViewController(animated: true)
        delegate?.alreadySignOut()
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
