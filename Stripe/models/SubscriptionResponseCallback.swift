//
//  SubscriptionResponseCallback.swift
//  Stripe Subscription Payment
//
//  Created by Vikas on 24/10/21.
//

import Foundation

protocol SubscriptionResponseProtocol {
    
    func onResult(subscriptionResult: SubscriptionResponse)
    func onError(message: String)
    
}
