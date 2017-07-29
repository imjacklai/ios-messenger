//
//  SignInController.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class SignInController: UIViewController {
    
    let signInRegisterView = SignInRegisterView(color: UIColor("#009688"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInRegisterView.delegate = self
        
        view.backgroundColor = .white
        view.addSubview(signInRegisterView)
        
        signInRegisterView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
}

extension SignInController: SignInRegisterViewDelegate {
    
    func signIn(email: String, password: String) {
        
    }
    
    func register(name: String, email: String, password: String) {
        
    }
    
}
