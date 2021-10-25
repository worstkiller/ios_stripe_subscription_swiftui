//
//  SubscriptionViewModel.swift
//  Stripe Subscription Payment
//
//  Created by Vikas on 24/10/21.
//

import Foundation
import Stripe

class SubscriptionViewModel: ObservableObject, SubscriptionResponseProtocol {
    
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var errorMessage: String? = nil
    @Published var isApiFailed: Bool = false
    @Published var isSuccessPayment: Bool = false
    
    init() {
        STPAPIClient.shared.publishableKey = AppConstants.STRIPE_PUBLISHING_KEY
    }
    
    func tokenization() {
        
        SubscriptionService.getSubscriptionToken(callback: self)
        
    }
    
    func onResult(subscriptionResult: SubscriptionResponse) {
        //success result from api
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "iOS Sample, Inc."
        configuration.customer = .init(id: subscriptionResult.customer, ephemeralKeySecret: subscriptionResult.ephemeralKey)
        configuration.primaryButtonColor = UIColor.init(.blue)
        DispatchQueue.main.async {
            self.paymentSheet = PaymentSheet(paymentIntentClientSecret: subscriptionResult.paymentIntent, configuration: configuration)
        }
    }
    
    
    func onError(message: String) {
        //some error during calling the api for tokenization
        self.errorMessage = message
    }
    
    func onPaymentCompletion(result: PaymentSheetResult?) {
          if let paymentFinal = result {
              switch paymentFinal {
              case .completed:
                  isSuccessPayment = true
              case .failed(let error):
                self.errorMessage = error.localizedDescription
                  self.isApiFailed = true
              case .canceled:
                  self.isApiFailed = false
              }
          }
      }
    
}
