//
//  CGRect+Helpers.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import CoreGraphics

public extension CGRect {
    // MARK: - Properties

    var center: CGPoint {
        get {
            CGPoint(x: midX, y: midY)
        }
        set {
            origin = CGPoint(x: newValue.x - width * 0.5, y: newValue.y - height * 0.5)
        }
    }

    // MARK: - Equality

    func isAlmostEqual(to other: CGRect) -> Bool {
        size.isAlmostEqual(to: other.size) && origin.isAlmostEqual(to: other.origin)
    }

    func isAlmostEqual(to other: CGRect, error: CGFloat) -> Bool {
        size.isAlmostEqual(to: other.size, error: error) && origin.isAlmostEqual(to: other.origin, error: error)
    }
}
