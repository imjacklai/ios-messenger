//
//  MessageInputView.swift
//  Messenger
//
//  Created by Jack Lai on 01/08/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit

protocol MessageInputViewDelegate: class {
    func sendText(text: String)
    func pickImage()
}

class MessageInputView: UIView {
    
    fileprivate let uploadImageView = UIImageView()
    fileprivate let inputTextField = CustomTextField()
    fileprivate let sendButton = UIButton(type: .system)
    
    weak var delegate: MessageInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        uploadImageView.image = #imageLiteral(resourceName: "picture")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImage)))
        
        inputTextField.placeholder = "訊息..."
        inputTextField.layer.cornerRadius = 5
        inputTextField.layer.borderWidth = 1
        inputTextField.layer.borderColor = UIColor("#DCDCDC").cgColor
        
        sendButton.setTitle("送出", for: .normal)
        sendButton.addTarget(self, action: #selector(sendText), for: .touchUpInside)
        
        let divider = UIView()
        divider.backgroundColor = UIColor("#DCDCDC")
        
        self.backgroundColor = .white
        self.addSubview(uploadImageView)
        self.addSubview(inputTextField)
        self.addSubview(sendButton)
        self.addSubview(divider)
        
        uploadImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.centerY.equalTo(self)
            make.left.equalTo(uploadImageView.snp.right).offset(10)
            make.right.equalTo(sendButton.snp.left)
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.right.bottom.equalTo(self)
        }
        
        divider.snp.makeConstraints { (make) in
            make.width.top.left.equalTo(self)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func pickImage() {
        delegate?.pickImage()
    }
    
    @objc fileprivate func sendText() {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        delegate?.sendText(text: text)
    }
    
    func clearTextField() {
        inputTextField.text = ""
    }
    
}
