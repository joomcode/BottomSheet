//
//  BottomSheetTransitioningDelegate.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 05.12.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

public protocol BottomSheetPresentationControllerFactory {
    func makeBottomSheetPresentationController(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?
    ) -> BottomSheetPresentationController
}

public final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    // MARK: - Private properties
    
    private weak var presentationController: BottomSheetPresentationController?
    private let factory: BottomSheetPresentationControllerFactory
    
    // MARK: - Init
    
    public init(factory: BottomSheetPresentationControllerFactory) {
        self.factory = factory
    }

    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        presentationController
    }
    
    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        presentationController
    }

    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        _presentationController(forPresented: presented, presenting: presenting, source: source)
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        presentationController?.interactiveTransitioning
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        presentationController?.interactiveTransitioning
    }
    
    // MARK: - Private methods
    
    private func _presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> BottomSheetPresentationController {
        if let presentationController = presentationController {
            return presentationController
        }
        
        let controller = factory.makeBottomSheetPresentationController(
            presentedViewController: presented,
            presentingViewController: presenting
        )
        
        presentationController = controller
        
        return controller
    }
}
