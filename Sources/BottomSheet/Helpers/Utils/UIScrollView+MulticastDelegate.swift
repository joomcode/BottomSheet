//
//  UIScrollView+MulticastDelegate.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

extension UIScrollView {
    private static var transitionKey: UInt8 = 0

    var multicastingDelegate: MulticastingScrollViewDelegate {
        if let object = objc_getAssociatedObject(self, &Self.transitionKey) as? MulticastingScrollViewDelegate {
            return object
        }
    
        let object = MulticastingScrollViewDelegate(target: self)
        objc_setAssociatedObject(self, &Self.transitionKey, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return object
    }
}

public final class MulticastingScrollViewDelegate: NSObject {
    private var delegates: NSHashTable<UIScrollViewDelegate> = .weakObjects()

    private var subscription: NSKeyValueObservation?
    private let target: UIScrollView

    init(target: UIScrollView) {
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
        subscription = target.observe(\.delegate, options: [.initial, .old, .new]) { [weak self] scrollView, change in
            guard let self = self else { return }

            let newValue = change.newValue ?? nil
            let oldValue = change.oldValue ?? nil
            guard oldValue !== newValue, newValue !== self else {
                return
            }
            
            if let newValue = newValue {
                self.addDelegate(newValue)
            }
            scrollView.delegate = self
        }
    }
    
    public func addDelegate(_ delegate: UIScrollViewDelegate) {
        if delegates.contains(delegate) {
            return
        }
        
        delegates.add(delegate)
        ensureUIKitCacheUpdated()
    }
    
    public func removeDelegate(_ delegate: UIScrollViewDelegate) {
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

extension MulticastingScrollViewDelegate: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for delegate in delegates.allObjects {
            delegate.scrollViewDidScroll?(scrollView)
        }
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        for delegate in delegates.allObjects {
            delegate.scrollViewDidZoom?(scrollView)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
       for delegate in delegates.allObjects {
           delegate.scrollViewWillBeginDragging?(scrollView)
       }
    }

    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        for delegate in delegates.allObjects {
            delegate.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        for delegate in delegates.allObjects {
            delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        for delegate in delegates.allObjects {
            delegate.scrollViewWillBeginDecelerating?(scrollView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for delegate in delegates.allObjects {
            delegate.scrollViewDidEndDecelerating?(scrollView)
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        for delegate in delegates.allObjects {
            delegate.scrollViewDidEndScrollingAnimation?(scrollView)
        }
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        for delegate in delegates.allObjects {
            if let view = delegate.viewForZooming?(in: scrollView) {
                return view
            }
        }
        
        return nil
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        for delegate in delegates.allObjects {
            delegate.scrollViewWillBeginZooming?(scrollView, with: view)
        }
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        for delegate in delegates.allObjects {
            delegate.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        }
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        for delegate in delegates.allObjects where delegate.scrollViewShouldScrollToTop?(scrollView) == true {
            return true
        }
        
        return false
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        for delegate in delegates.allObjects {
            delegate.scrollViewDidScrollToTop?(scrollView)
        }
    }

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        for delegate in delegates.allObjects {
            delegate.scrollViewDidChangeAdjustedContentInset?(scrollView)
        }
    }
}
