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
    fileprivate let messageLabel = UILabel()
    fileprivate let timeLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 24
        profileImageView.layer.masksToBounds = true
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .darkGray
        
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = .lightGray
        timeLabel.textAlignment = .right
        
        let containerView = UIView()
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(containerView)
        
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(48)
            make.left.equalTo(contentView).offset(10)
            make.centerY.equalTo(contentView)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel)
            make.bottom.equalTo(messageLabel)
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.right.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(containerView)
            make.right.equalTo(timeLabel.snp.left)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.right.equalTo(containerView)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.right.equalTo(containerView)
            make.centerY.equalTo(nameLabel)
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
        
        if let lastMessage = user.lastMessage {
            messageLabel.text = lastMessage
            messageLabel.isHidden = false
        } else {
            messageLabel.isHidden = true
        }
        
        if let timestamp = user.timestamp {
            timeLabel.text = Date(timeIntervalSince1970: timestamp / 1000).timeAgo()
            timeLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
        }
    }
    
}
