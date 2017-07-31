//
//  UserCell.swift
//  Messenger
//
//  Created by Jack Lai on 31/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    var user: User? {
        didSet { setupUser() }
    }
    
    fileprivate let profileImageView = UIImageView()
    fileprivate let nameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 24
        profileImageView.layer.masksToBounds = true
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(48)
            make.left.equalTo(contentView).offset(10)
            make.centerY.equalTo(contentView)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.centerY.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUser() {
        guard let user = user else { return }
        
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: user.profileImageUrl, placeholder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = user.name
    }
    
}
