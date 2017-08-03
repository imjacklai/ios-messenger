//
//  Extensions.swift
//  Messenger
//
//  Created by Jack Lai on 03/08/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit

extension String {
    
    func estimateFrame(withConstrainedWidth width: CGFloat, fontSize: CGFloat) -> CGRect {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        return self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)], context: nil)
    }
    
}
