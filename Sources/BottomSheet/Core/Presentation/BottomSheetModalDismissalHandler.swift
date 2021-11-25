//
//  BottomSheetModalDismissalHandler.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

public protocol BottomSheetModalDismissalHandler {
    var canBeDismissed: Bool { get }

    func performDismissal(animated: Bool)
}
