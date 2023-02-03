//
//  CGSize+Helpers.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 08.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import CoreGraphics

extension CGSize {
    static func uniform(_ side: CGFloat) -> CGSize {
        CGSize(width: side, height: side)
    }

    // MARK: - Equality

    func isAlmostEqual(to other: CGSize) -> Bool {
        width.isAlmostEqual(to: other.width) && height.isAlmostEqual(to: other.height)
    }

    func isAlmostEqual(to other: CGSize, error: CGFloat) -> Bool {
        width.isAlmostEqual(to: other.width, error: error) && height.isAlmostEqual(to: other.height, error: error)
    }
}
