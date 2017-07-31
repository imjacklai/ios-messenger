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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
    }
    
}
