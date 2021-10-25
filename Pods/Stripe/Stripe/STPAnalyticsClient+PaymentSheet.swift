//
//  STPAnalyticsClient+PaymentSheet.swift
//  StripeiOS
//
//  Created by Yuki Tokuhiro on 12/14/20.
//  Copyright © 2020 Stripe, Inc. All rights reserved.
//

import Foundation
@_spi(STP) import StripeCore

extension STPAnalyticsClient {
    // MARK: - Log events
    func logPaymentSheetInitialized(
        isCustom: Bool = false, configuration: PaymentSheet.Configuration
    ) {
        logPaymentSheetEvent(event: paymentSheetInitEventValue(
                                isCustom: isCustom,
                                configuration: configuration))
    }

    func logPaymentSheetPayment(
        isCustom: Bool,
        paymentMethod: AnalyticsPaymentMethodType,
        result: PaymentSheetResult
    ) {
        var success = false
        switch result {
        case .canceled:
            // We don't report these to analytics, bail out.
            return
        case .failed(error: _):
            success = false
        case .completed:
            success = true
        }
        
        logPaymentSheetEvent(event: paymentSheetPaymentEventValue(
                                isCustom: isCustom,
                                paymentMethod: paymentMethod,
                                success: success))
    }

    func logPaymentSheetShow(
        isCustom: Bool,
        paymentMethod: AnalyticsPaymentMethodType
    ) {
        logPaymentSheetEvent(event: paymentSheetShowEventValue(
                                isCustom: isCustom,
                                paymentMethod: paymentMethod))
    }
    
    func logPaymentSheetPaymentOptionSelect(
        isCustom: Bool,
        paymentMethod: AnalyticsPaymentMethodType
    ) {
        logPaymentSheetEvent(event: paymentSheetPaymentOptionSelectEventValue(
                                isCustom: isCustom,
                                paymentMethod: paymentMethod))
    }


    // MARK: - String builders
    enum AnalyticsPaymentMethodType : String {
        case newPM = "newpm"
        case savedPM = "savedpm"
        case applePay = "applepay"
    }
    
    private static let mc = "mc"
    
    private func customOrComplete(_ isCustom: Bool) -> String {
        isCustom ? "custom" : "complete"
    }
    
    func paymentSheetInitEventValue(isCustom: Bool, configuration: PaymentSheet.Configuration)
        -> String
    {
        return [
            Self.mc,
            customOrComplete(isCustom),
            "init",
            configuration.customer != nil ? "customer" : nil,
            configuration.applePay != nil ? "applepay" : nil,
            configuration.customer == nil && configuration.applePay == nil ? "default" : nil,
        ].compactMap({ $0 }).joined(separator: "_")
    }
    
    func paymentSheetShowEventValue(
        isCustom: Bool,
        paymentMethod: AnalyticsPaymentMethodType
    ) -> String
    {
        return [
            Self.mc,
            customOrComplete(isCustom),
            "sheet",
            paymentMethod.rawValue,
            "show",
        ].compactMap({ $0 }).joined(separator: "_")
    }
    
    func paymentSheetPaymentEventValue(
        isCustom: Bool,
        paymentMethod: AnalyticsPaymentMethodType,
        success: Bool
    ) -> String
    {
        return [
            Self.mc,
            customOrComplete(isCustom),
            "payment",
            paymentMethod.rawValue,
            success ? "success" : "failure"
        ].compactMap({ $0 }).joined(separator: "_")
    }
    
    func paymentSheetPaymentOptionSelectEventValue(
        isCustom: Bool,
        paymentMethod: AnalyticsPaymentMethodType
    ) -> String
    {
        return [
            Self.mc,
            customOrComplete(isCustom),
            "paymentoption",
            paymentMethod.rawValue,
            "select"
        ].compactMap({ $0 }).joined(separator: "_")
    }

    // MARK: - Internal
    private func logPaymentSheetEvent(event: String) {
        var payload = commonPayload()
        if isSimulatorOrTest {
            payload["is_development"] = true
        }
        payload["event"] = event
        payload["additional_info"] = additionalInfo()

        // TODO(mludowise): DRY this up with `PaymentAnalytic`
        payload["apple_pay_enabled"] = NSNumber(value: StripeAPI.deviceSupportsApplePay())
        payload["ocr_type"] = STPAnalyticsClient.ocrTypeString()
        payload["ui_usage_level"] = STPAnalyticsClient.uiUsageLevelString(from: productUsage)
        payload["product_usage"] = productUsage.sorted()

        logPayload(payload)
    }
    
    private var isSimulatorOrTest: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return NSClassFromString("XCTest") != nil
        #endif
    }
    
}

extension PaymentSheetViewController.Mode {
    var analyticsValue : STPAnalyticsClient.AnalyticsPaymentMethodType {
        switch self {
        case .addingNew:
            return .newPM
        case .selectingSaved:
            return .savedPM
        }
    }
}

extension ChoosePaymentOptionViewController.Mode {
    var analyticsValue : STPAnalyticsClient.AnalyticsPaymentMethodType {
        switch self {
        case .addingNew:
            return .newPM
        case .selectingSaved:
            return .savedPM
        }
    }
}

extension SavedPaymentOptionsViewController.Selection {
    var analyticsValue : STPAnalyticsClient.AnalyticsPaymentMethodType {
        switch self {
        case .add:
            return .newPM
        case .saved(paymentMethod: _):
            return .savedPM
        case .applePay:
            return .applePay
        }
    }
}

extension PaymentSheet.PaymentOption {
    var analyticsValue : STPAnalyticsClient.AnalyticsPaymentMethodType {
        switch self {
        case .applePay:
            return .applePay
        case .new:
            return .newPM
        case .saved:
            return .savedPM
        }
    }
}
