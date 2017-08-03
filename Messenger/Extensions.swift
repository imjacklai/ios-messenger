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

extension Date {
    
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: self, to: now, options: [])
        
        if let day = components.day, day >= 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: self)
        }
        
        if let hour = components.hour, hour >= 1 {
            return "\(hour)小時前"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "\(minute)分鐘前"
        }
        
        if let second = components.second, second >= 3 {
            return "\(second)秒鐘前"
        }
        
        return "剛剛"
    }
    
}
