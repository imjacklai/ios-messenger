//
//  ChatController.swift
//  Messenger
//
//  Created by Jack Lai on 31/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ChatController: UICollectionViewController {
    
    var user: User? {
        didSet { navigationItem.title = user?.name }
    }
    
    fileprivate let messageInputView = MessageInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        messageInputView.delegate = self
    }
    
    override var inputAccessoryView: UIView? {
        return messageInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    fileprivate func sendMessage(properties: [String: Any]) {
        let toId = user!.uid
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = (Date().timeIntervalSince1970 * 1000).rounded()
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String: Any]
        properties.forEach { values[$0] = $1 }
        
        Database.database().reference().child("messages").childByAutoId().updateChildValues(values) { (error, ref) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "發送訊息失敗")
                print("Failed to send message: ", error)
                return
            }
            
            let messageId = ref.key
            
            Database.database().reference().child("user-message").child(fromId).child(toId).updateChildValues([messageId: 1])
            Database.database().reference().child("user-message").child(toId).child(fromId).updateChildValues([messageId: 1])
            Database.database().reference().child("user-list").child(fromId).child(toId).setValue([messageId: 1])
            Database.database().reference().child("user-list").child(toId).child(fromId).setValue([messageId: 1])
            
            self.messageInputView.clearTextField()
        }
    }
    
}

extension ChatController: MessageInputViewDelegate {
    
    func sendText(text: String) {
        sendMessage(properties: ["text": text])
    }
    
}
