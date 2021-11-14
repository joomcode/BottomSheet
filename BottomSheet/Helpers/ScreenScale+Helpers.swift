//
//  ScreenScale+Helpers.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 08.12.2019.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

public var pixelSize: CGFloat {
    let scale = UIScreen.mainScreenScale
    return 1.0 / scale
}

public extension CGFloat {
    var pixelCeiled: CGFloat {
        let scale = UIScreen.mainScreenScale
        return Darwin.ceil(self * scale) / scale
    }
}

public extension CGPoint {
    var pixelCeiled: CGPoint {
        CGPoint(x: x.pixelCeiled, y: y.pixelCeiled)
    }
}

public extension CGSize {
    var pixelCeiled: CGSize {
        CGSize(width: width.pixelCeiled, height: height.pixelCeiled)
    }
}

public extension UIScreen {
    static let mainScreenScale = UIScreen.main.scale
    static let mainScreenPixelSize = CGFloat(1.0) / mainScreenScale
}
