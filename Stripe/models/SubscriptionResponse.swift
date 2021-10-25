//
//  SubscriptionResponse.swift
//  Stripe Subscription Payment
//
//  Created by Vikas on 24/10/21.
//

import Foundation

struct SubscriptionResponse : Decodable{
    
    let paymentIntent: String
    let publishableKey: String
    let customer: String
    let ephemeralKey: String
    
    enum CodingKeys: String, CodingKey {
        case paymentIntent
        case publishableKey
        case customer
        case ephemeralKey
    }
    
}
