//
//  SubscriptionService.swift
//  Stripe Subscription Payment
//
//  Created by Vikas on 24/10/21.
//

import Foundation
import Alamofire

struct SubscriptionService {
    
    private static let API_ENDPOINT = "https://lowly-evening-plant.glitch.me"
    
    static func getSubscriptionToken(callback: SubscriptionResponseProtocol){
        
        AF.request("\(API_ENDPOINT)/checkout", method: .post).responseDecodable(of: SubscriptionResponse.self){response in
            
            guard let result  = response.value else {
                
                callback.onError(message: response.error?.errorDescription ?? "Something went wrong, please try again!")
                return
            }
            
            callback.onResult(subscriptionResult: result)
        }
    }
    
}
