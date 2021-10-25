//
//  Utils.swift
//  Stripe Subscription Payment
//
//  Created by Vikas on 24/10/21.
//

import Foundation
import SwiftUI

struct Utils {
    
    //get color object to be used in swiftui  from UIColor
        static func getColor (_ hex:String) -> Color {
            var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            
            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }
            
            if ((cString.count) != 6) {
                return Color.gray
            }
            
            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)
            
            let uiColor = UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0))
            
            return Color(uiColor)
        }
    
}
