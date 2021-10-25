//
//  AppDelegate.swift
//  Stripe Subscription Payment
//
//  Created by Vikas on 24/10/21.
//

import Foundation
import SwiftUI
import Stripe

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        StripeAPI.defaultPublishableKey = AppConstants.STRIPE_PUBLISHING_KEY
        return true
    }
    
}
