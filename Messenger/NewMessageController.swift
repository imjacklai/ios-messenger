//
//  NewMessageController.swift
//  Messenger
//
//  Created by Jack Lai on 31/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    fileprivate let indicator = UIActivityIndicatorView()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "傳訊息給..."
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.rowHeight = 72
        
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        
        tableView.addSubview(indicator)
        
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(tableView)
        }
        
        fetchUsers()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    @objc fileprivate func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func fetchUsers() {
        indicator.startAnimating()
        
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: String] else { return }
            
            // Do not add the current user (self) into user array.
            if Auth.auth().currentUser?.uid == snapshot.key { return }
            
            let user = User(uid: snapshot.key, dictionary: dictionary)
            self.users.append(user)
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.tableView.reloadData()
            }
        })
    }
    
}
