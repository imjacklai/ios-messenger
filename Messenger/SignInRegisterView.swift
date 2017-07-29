//
//  SignInRegisterView.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import SnapKit

protocol SignInRegisterViewDelegate {
    func signIn(email: String, password: String)
    func register(name: String, email: String, password: String)
}

class SignInRegisterView: UIView {
    
    let segmentedControl = UISegmentedControl(items: ["登入", "註冊"])
    let nameTextField = CustomTextField()
    let emailTextField = CustomTextField()
    let passwordTextField = CustomTextField()
    let submitButton = UIButton(type: .system)
    
    var delegate: SignInRegisterViewDelegate?
    
    init(color: UIColor) {
        super.init(frame: CGRect.zero)
        
        segmentedControl.tintColor = color
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged), for: .valueChanged)
        
        let textFields = [nameTextField, emailTextField, passwordTextField]
        
        nameTextField.placeholder = "名稱"
        nameTextField.returnKeyType = .next
        nameTextField.isHidden = true
        
        emailTextField.placeholder = "信箱"
        emailTextField.returnKeyType = .next
        emailTextField.keyboardType = .emailAddress
        
        passwordTextField.placeholder = "密碼"
        passwordTextField.returnKeyType = .done
        passwordTextField.isSecureTextEntry = true
        
        for (index, textField) in textFields.enumerated() {
            textField.tag = index
            textField.layer.cornerRadius = 5
            textField.layer.borderWidth = 1
            textField.layer.borderColor = color.cgColor
            textField.clearButtonMode = .whileEditing
            textField.delegate = self
        }
        
        submitButton.setTitle("登入", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = color
        submitButton.layer.cornerRadius = 5
        submitButton.layer.masksToBounds = true
        submitButton.addTarget(self, action: #selector(handleSignInOrRegister), for: .touchUpInside)
        
        self.addSubview(segmentedControl)
        self.addSubview(nameTextField)
        self.addSubview(emailTextField)
        self.addSubview(passwordTextField)
        self.addSubview(submitButton)
        
        self.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(segmentedControl)
            make.bottom.equalTo(submitButton)
        }
        
        segmentedControl.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 250, height: 30))
            make.top.centerX.equalTo(self)
        }
        
        nameTextField.snp.makeConstraints { (make) in
            make.width.equalTo(segmentedControl)
            make.height.equalTo(0)
            make.top.equalTo(segmentedControl.snp.bottom).offset(0)
            make.centerX.equalTo(self)
        }
        
        emailTextField.snp.makeConstraints { (make) in
            make.width.equalTo(segmentedControl)
            make.height.equalTo(40)
            make.top.equalTo(nameTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.width.equalTo(segmentedControl)
            make.height.equalTo(40)
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
        }
        
        submitButton.snp.makeConstraints { (make) in
            make.width.equalTo(segmentedControl)
            make.height.equalTo(40)
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func segmentedValueChanged() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        
        nameTextField.snp.updateConstraints { (make) in
            make.height.equalTo(selectedIndex == 0 ? 0 : 40)
            make.top.equalTo(segmentedControl.snp.bottom).offset(selectedIndex == 0 ? 0 : 10)
        }
        
        nameTextField.isHidden = selectedIndex == 0
        submitButton.setTitle(selectedIndex == 0 ? "登入" : "註冊", for: .normal)
        
        UIView.animate(withDuration: 0.3) { 
            self.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func handleSignInOrRegister() {
        self.endEditing(true)
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let email = emailTextField.text, !email.isEmpty,
                let password = passwordTextField.text, !password.isEmpty else {
                print("請輸入完整")
                return
            }
            delegate?.signIn(email: email, password: password)
        } else {
            guard let name = nameTextField.text, !name.isEmpty,
                let email = emailTextField.text, !email.isEmpty,
                let password = passwordTextField.text, !password.isEmpty else {
                print("請輸入完整")
                return
            }
            delegate?.register(name: name, email: email, password: password)
        }
    }
    
}

extension SignInRegisterView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? CustomTextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
}
