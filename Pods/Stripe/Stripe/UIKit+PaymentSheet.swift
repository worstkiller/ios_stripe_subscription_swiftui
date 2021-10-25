//
//  UIKit+PaymentSheet.swift
//  StripeiOS
//
//  Created by Yuki Tokuhiro on 11/10/20.
//  Copyright © 2020 Stripe, Inc. All rights reserved.
//

import Foundation
import PassKit
import UIKit
@_spi(STP) import StripeCore

enum PaymentSheetUI {
    /// The padding between views in the sheet e.g., between the bottom of the form and the Pay button
    static let defaultPadding: CGFloat = 20
    static let defaultMargins: NSDirectionalEdgeInsets = .insets(
        leading: defaultPadding, trailing: defaultPadding)
    static let defaultSheetMargins: NSDirectionalEdgeInsets = .insets(
        leading: defaultPadding, bottom: 36, trailing: defaultPadding)
    /// The distances between a textfield and its containing view
    static let textfieldInsets: NSDirectionalEdgeInsets = .insets(top: 4, leading: 14, bottom: 6, trailing: 14)
    static let fieldBorderColor: UIColor = .lightGray
    static let fieldBorderWidth: CGFloat = 0.5
    static let defaultButtonCornerRadius: CGFloat = 6
    static let defaultShadowOpacity: Float = 0.2
    static let defaultShadowRadius: CGFloat = 1.5
    static let minimumTapSize: CGSize = CGSize(width: 44, height: 44)
    static let defaultAnimationDuration: TimeInterval = 0.2
    static let quickAnimationDuration: TimeInterval = 0.1
    /// The minimnum amount of time to spend processing before transitioning to success/failure
    static let minimumFlightTime: TimeInterval = 1
    static let delayBetweenSuccessAndDismissal: TimeInterval = 1.5
    static let backgroundColor: UIColor = {
        // systemBackground has a 'base' and 'elevated' state; we don't want this behavior.
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return CompatibleColor.secondarySystemBackground
                default:
                    return CompatibleColor.systemBackground
                }
            }
        } else {
            return CompatibleColor.systemBackground
        }
    }()

    static func makeErrorLabel() -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    static func makeHeaderLabel() -> UILabel {
        let header = UILabel()
        header.textColor = CompatibleColor.label
        header.numberOfLines = 2
        header.font = .preferredFont(forTextStyle: .title3, weight: .bold)
        header.accessibilityTraits = [.header]
        return header
    }

    static func makeInputLabel() -> UILabel {
        let label = UILabel()
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        let font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.font = fontMetrics.scaledFont(for: font)
        label.textColor = CompatibleColor.secondaryLabel
        label.accessibilityTraits = [.header]
        return label
    }
}

extension PKPaymentButtonStyle {
    static var compatibleAutomatic: PKPaymentButtonStyle {
        if #available(iOS 14.0, *) {
            return .automatic
        } else {
            return .black
        }
    }
}

extension UIViewController {
    func switchContentIfNecessary(
        to toVC: UIViewController, containerView: DynamicHeightContainerView
    ) {
        assert(children.count <= 1)
        // Swap out child view controllers if necessary
        if let fromVC = children.first {
            if fromVC == toVC {
                return
            }

            // Add the new one
            self.addChild(toVC)
            toVC.view.alpha = 0
            containerView.addPinnedSubview(toVC.view)
            containerView.layoutIfNeeded()  // Lay the view out now or it animates layout from a zero size

            animateHeightChange(
                {
                    containerView.updateHeight()
                    toVC.didMove(toParent: self)
                    fromVC.view.alpha = 0
                    toVC.view.alpha = 1
                },
                completion: { _ in
                    // Remove the old one
                    self.remove(childViewController: fromVC)
                    UIAccessibility.post(notification: .screenChanged, argument: toVC.view)
                })
        } else {
            addChild(toVC)
            containerView.addPinnedSubview(toVC.view)
            containerView.updateHeight()
            toVC.didMove(toParent: self)
            containerView.setNeedsLayout()
            containerView.layoutIfNeeded()
            UIAccessibility.post(notification: .screenChanged, argument: toVC.view)
        }
    }

    func remove(childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
        childViewController.didMove(toParent: nil)
    }

    /// Use this to animate changes that affect the height of the sheet
    func animateHeightChange(_ animations: STPVoidBlock? = nil, completion: ((Bool) -> Void)? = nil)
    {
        let params = UISpringTimingParameters()
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: params)

        if let animations = animations {
            animator.addAnimations(animations)
        }
        animator.addAnimations {
            // Unless we lay out the container view, the layout jumps
            self.rootParent.presentationController?.containerView?.layoutIfNeeded()
        }
        if let completion = completion {
            animator.addCompletion { _ in
                completion(true)
            }
        }
        animator.startAnimation()
    }

    var rootParent: UIViewController {
        if let parent = parent {
            return parent.rootParent
        }
        return self
    }
}
