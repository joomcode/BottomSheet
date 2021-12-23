//
//  UINavigationController+MulticastDelegate.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

extension UINavigationController {
    private static var transitionKey: UInt8 = 0

    var multicastingDelegate: MulticastingNavigationControllerDelegate {
        if let object = objc_getAssociatedObject(self, &Self.transitionKey) as? MulticastingNavigationControllerDelegate {
            return object
        }
    
        let object = MulticastingNavigationControllerDelegate(target: self)
        objc_setAssociatedObject(object, &Self.transitionKey, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return object
    }
}

public final class MulticastingNavigationControllerDelegate: NSObject {
    private var delegates: NSHashTable<UINavigationControllerDelegate> = .weakObjects()

    private var subscription: NSKeyValueObservation?
    private let target: UINavigationController

    init(target: UINavigationController) {
        self.target = target
        super.init()
        
        addInitialDelegate()
        ensureMutlicastIsSet()
    }
    
    deinit {
        subscription?.invalidate()
    }
    
    private func addInitialDelegate() {
        if let delegate = target.delegate, delegate !== self {
            target.delegate = self

            addDelegate(delegate)
        }
    }
    
    private func ensureMutlicastIsSet() {
        subscription = target.observe(\.delegate, options: [.initial, .old, .new]) { [weak self] navigationController, change in
            guard let self = self else { return }

            let newValue = change.newValue ?? nil
            let oldValue = change.oldValue ?? nil
            guard oldValue !== newValue, newValue !== self else {
                return
            }
            
            if let newValue = newValue {
                self.addDelegate(newValue)
            }
            navigationController.delegate = self
        }
    }
    
    public func addDelegate(_ delegate: UINavigationControllerDelegate) {
        if delegates.contains(delegate) {
            return
        }
        
        delegates.add(delegate)
        ensureUIKitCacheUpdated()
    }
    
    public func removeDelegate(_ delegate: UINavigationControllerDelegate) {
        if !delegates.contains(delegate) {
            return
        }
        
        delegates.remove(delegate)
        ensureUIKitCacheUpdated()
    }
    
    private func ensureUIKitCacheUpdated() {
        target.delegate = nil
        target.delegate = self
    }
}

extension MulticastingNavigationControllerDelegate: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        for delegate in delegates.allObjects {
            delegate.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        for delegate in delegates.allObjects {
            delegate.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
    }

    public func navigationControllerSupportedInterfaceOrientations(
        _ navigationController: UINavigationController
    ) -> UIInterfaceOrientationMask {
        for delegate in delegates.allObjects {
            if let result = delegate.navigationControllerSupportedInterfaceOrientations?(navigationController) {
                return result
            }
        }
        
        return .all
    }

    public func navigationControllerPreferredInterfaceOrientationForPresentation(
        _ navigationController: UINavigationController
    ) -> UIInterfaceOrientation {
        for delegate in delegates.allObjects {
            if let result = delegate.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) {
                return result
            }
        }
        
        return .portrait
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        for delegate in delegates.allObjects {
            if let result = delegate.navigationController?(navigationController, interactionControllerFor: animationController) {
                return result
            }
        }
        
        return nil
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        for delegate in delegates.allObjects {
            if let result = delegate.navigationController?(
                navigationController,
                animationControllerFor: operation,
                from: fromVC,
                to: toVC
            ) {
                return result
            }
        }
        
        return nil
    }
}
