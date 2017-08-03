//
//  Message.swift
//  Messenger
//
//  Created by Jack Lai on 03/08/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    var fromId: String
    var toId: String
    var timestamp: Double
    var text: String?
    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as! String
        self.toId = dictionary["toId"] as! String
        self.timestamp = dictionary["timestamp"] as! Double
        self.text = dictionary["text"] as? String
    }
    
    func chatPartner() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
}
