//
//  ChatController.swift
//  Messenger
//
//  Created by Jack Lai on 31/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit

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
    
}

extension ChatController: MessageInputViewDelegate {
    
    func sendText(text: String) {
        
    }
    
}
