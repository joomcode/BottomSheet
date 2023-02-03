//
//  UIViewController+Lifecycle.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 16.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

@objc
public enum ViewControllerEvent: Int {
    case viewDidLoad
    case viewWillAppear
    case viewDidAppear
    case viewWillDisappear
    case viewDidDisappear
}

public extension UIViewController {
    private static var key: UInt8 = 0

    typealias EventListener = () -> Void

    private var listeners: [EventListener] {
        get {
            guard let listeners = objc_getAssociatedObject(self, &Self.key) as? [EventListener] else {
                return []
            }

            return listeners
        }
        set {
            objc_setAssociatedObject(self, &Self.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    static func swiftLoad() {
        if self !== UIViewController.self {
            return
        }

        let originalToSwizzled = [
            #selector(viewDidLoad): #selector(swizzled_viewDidLoad),
            #selector(viewWillAppear(_:)): #selector(swizzled_viewWillAppear(_:)),
            #selector(viewDidAppear(_:)): #selector(swizzled_viewDidAppear(_:)),
            #selector(viewWillDisappear(_:)): #selector(swizzled_viewWillDisappear(_:)),
            #selector(viewDidDisappear(_:)): #selector(swizzled_viewDidDisappear(_:)),
        ]

        for (originalSelector, swizzledSelector) in originalToSwizzled {
            guard
                let originalMethod = class_getInstanceMethod(self, originalSelector),
                let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            else { return }

            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }

    @objc
    private func swizzled_viewDidLoad() {
        swizzled_viewDidLoad()

        notifyEvent(.viewDidLoad)
    }

    @objc
    private func swizzled_viewWillAppear(_ animated: Bool) {
        swizzled_viewWillAppear(animated)

        notifyEvent(.viewWillAppear)
    }

    @objc
    private func swizzled_viewDidAppear(_ animated: Bool) {
        swizzled_viewDidAppear(animated)

        notifyEvent(.viewDidAppear)
    }

    @objc
    private func swizzled_viewWillDisappear(_ animated: Bool) {
        swizzled_viewWillDisappear(animated)

        notifyEvent(.viewWillDisappear)
    }

    @objc
    private func swizzled_viewDidDisappear(_ animated: Bool) {
        swizzled_viewDidDisappear(animated)

        notifyEvent(.viewDidDisappear)
    }

    private func notifyEvent(_ event: ViewControllerEvent) {
        listeners.forEach {
            $0()
        }
    }

    func subscribe(onEvent: ViewControllerEvent, listener: @escaping EventListener) {
        listeners.append(listener)
    }
}
