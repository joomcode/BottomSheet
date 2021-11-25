//
//  UIEdgeInsets+Helpers.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 22.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

public extension UIEdgeInsets {
    // MARK: - Public properties

    @inlinable
    var horizontalInsets: CGFloat {
        left + right
    }

    @inlinable
    var verticalInsets: CGFloat {
        top + bottom
    }
}
