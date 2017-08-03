//
//  MessageCell.swift
//  Messenger
//
//  Created by Jack Lai on 03/08/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class MessageCell: UICollectionViewCell {
    
    fileprivate let profileImageView = UIImageView()
    fileprivate let bubbleView = UIView()
    fileprivate let textView = UITextView()
    
    fileprivate var bubbleViewLeftConstraint: Constraint?
    fileprivate var bubbleViewRightConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        profileImageView.layer.cornerRadius = 16
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.tintColor = UIColor("#FF6F00")
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .all
        
        bubbleView.addSubview(textView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(bubbleView)
        
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
            make.left.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView)
        }
        
        bubbleView.snp.makeConstraints { (make) in
            self.bubbleViewLeftConstraint = make.left.equalTo(profileImageView.snp.right).offset(10).constraint
            self.bubbleViewRightConstraint = make.right.equalTo(contentView).offset(-10).constraint
            make.width.equalTo(200)
            make.top.height.equalTo(contentView)
        }
        
        textView.snp.makeConstraints { (make) in
            make.edges.equalTo(bubbleView).inset(UIEdgeInsetsMake(0, 10, 0, 10))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMessage(partner: User, message: Message) {
        if message.fromId == Auth.auth().currentUser?.uid {
            // Message from self
            profileImageView.isHidden = true
            bubbleView.backgroundColor = UIColor("#0089F9")
            textView.textColor = .white
            bubbleViewLeftConstraint?.deactivate()
            bubbleViewRightConstraint?.activate()
        } else {
            // Message from partner
            if let profileImageUrl = partner.profileImageUrl {
                profileImageView.kf.setImage(with: profileImageUrl)
            }
            profileImageView.isHidden = false
            bubbleView.backgroundColor = UIColor("#F0F0F0")
            textView.textColor = .black
            bubbleViewLeftConstraint?.activate()
            bubbleViewRightConstraint?.deactivate()
        }
        
        if let text = message.text {
            textView.text = text
            textView.isHidden = false
            bubbleView.snp.updateConstraints({ (make) in
                make.width.equalTo(text.estimateFrame(withConstrainedWidth: 200, fontSize: 16).width + 32)
            })
        }
    }
    
}
