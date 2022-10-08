//
//  UINavigationController+MulticastDelegate.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

// cocoapods
#if canImport(BottomSheetUtils)
import BottomSheetUtils
#endif

extension UINavigationController {
    private static var transitionKey: UInt8 = 0

    public var multicastingDelegate: MulticastDelegate {
        if let object = objc_getAssociatedObject(self, &Self.transitionKey) as? MulticastDelegate {
            return object
        }

        let object = MulticastDelegate(
            target: self,
            delegateGetter: #selector(getter: delegate),
            delegateSetter: #selector(setter: delegate)
        )
        objc_setAssociatedObject(self, &Self.transitionKey, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return object
    }
}
