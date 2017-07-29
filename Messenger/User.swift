//
//  User.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import Foundation

class User {
    
    var uid: String
    var name: String
    var email: String
    var profileImageUrl: URL?
    
    init(uid: String, dictionary: [String: String]) {
        self.uid = uid
        self.name = dictionary["name"] ?? ""
        self.email = dictionary["email"] ?? ""
 
        if let profileImage = dictionary["profileImageUrl"], let profileImageUrl = URL(string: profileImage) {
            self.profileImageUrl = profileImageUrl
        }
    }
    
}
