//
//  MessageListController.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase

class MessageListController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Messenger"
        checkUserSignIn()
    }
    
    private func checkUserSignIn() {
        guard let uid = Auth.auth().currentUser?.uid else {
            present(SignInController(), animated: true, completion: nil)
            return
        }
        
        print(uid)
    }
    
}
