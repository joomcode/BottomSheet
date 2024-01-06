//
//  UIViewController+Convenience.swift
//  BottomSheetDemo
//
//  Created by Mikhail Maslo on 15.08.2022.
//  Copyright © 2022 Joom. All rights reserved.
//

import UIKit

public final class DefaultBottomSheetPresentationControllerFactory: BottomSheetPresentationControllerFactory {
    // MARK: - Nested types

    public typealias DismissalHandlerProvider = () -> BottomSheetModalDismissalHandler

    // MARK: - Public properties

    private let configuration: BottomSheetConfiguration
    private let dismissalHandlerProvider: DismissalHandlerProvider

    // MARK: - Init

    public init(
        configuration: BottomSheetConfiguration,
        dismissalHandlerProvider: @escaping DismissalHandlerProvider
    ) {
        self.dismissalHandlerProvider = dismissalHandlerProvider
        self.configuration = configuration
    }

    // MARK: - BottomSheetPresentationControllerFactory

    public func makeBottomSheetPresentationController(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?
    ) -> BottomSheetPresentationController {
        BottomSheetPresentationController(
            presentedViewController: presentedViewController,
            presentingViewController: presentingViewController,
            dismissalHandler: dismissalHandlerProvider(),
            configuration: configuration
        )
    }
}

public final class DefaultBottomSheetModalDismissalHandler: BottomSheetModalDismissalHandler {
    // MARK: - Private properties

    private weak var presentingViewController: UIViewController?
    private let _canBeDismissed: () -> Bool
    private let dismissCompletion: (() -> Void)?

    private var didInvokeDismissal = false

    // MARK: - Init

    init(
        presentingViewController: UIViewController?,
        canBeDismissed: @escaping (() -> Bool),
        dismissCompletion: (() -> Void)?
    ) {
        self.presentingViewController = presentingViewController
        self._canBeDismissed = canBeDismissed
        self.dismissCompletion = dismissCompletion
    }

    // MARK: - BottomSheetModalDismissalHandler

    public var canBeDismissed: Bool {
        _canBeDismissed()
    }

    public func performDismissal(animated: Bool) {
        if let presentedViewController = presentingViewController?.presentedViewController {
            presentedViewController.dismiss(animated: animated, completion: dismissCompletion)
        } else {
            // User dismissed view controller by swipe-gesture, dismiss handler wasn't invoked
            dismissCompletion?()
        }

        didInvokeDismissal = true
    }

    public func didEndDismissal() {
        guard !didInvokeDismissal else { return }

        dismissCompletion?()
    }
}

public extension UIViewController {
    private(set) var bottomSheetTransitionDelegate: UIViewControllerTransitioningDelegate? {
        get { objc_getAssociatedObject(self, &Self.bottomSheetTransitionDelegateKey) as? UIViewControllerTransitioningDelegate }
        set { objc_setAssociatedObject(self, &Self.bottomSheetTransitionDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private static var bottomSheetTransitionDelegateKey: UInt8 = 0

    func presentBottomSheet(
        viewController: UIViewController,
        configuration: BottomSheetConfiguration,
        canBeDismissed: @escaping (() -> Bool) = { true },
        dismissCompletion: (() -> Void)? = nil
    ) {
        weak var presentingViewController = self
        weak var currentBottomSheetTransitionDelegate: UIViewControllerTransitioningDelegate?
        let presentationControllerFactory = DefaultBottomSheetPresentationControllerFactory(configuration: configuration) {
            DefaultBottomSheetModalDismissalHandler(presentingViewController: presentingViewController, canBeDismissed: canBeDismissed) {
                if currentBottomSheetTransitionDelegate === presentingViewController?.bottomSheetTransitionDelegate {
                    presentingViewController?.bottomSheetTransitionDelegate = nil
                }
                dismissCompletion?()
            }
        }
        bottomSheetTransitionDelegate = BottomSheetTransitioningDelegate(
            presentationControllerFactory: presentationControllerFactory
        )
        currentBottomSheetTransitionDelegate = bottomSheetTransitionDelegate
        viewController.transitioningDelegate = bottomSheetTransitionDelegate
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true, completion: nil)
    }

    func presentBottomSheetInsideNavigationController(
        viewController: UIViewController,
        configuration: BottomSheetConfiguration,
        canBeDismissed: @escaping (() -> Bool) = { true },
        dismissCompletion: (() -> Void)? = nil
    ) {
        let navigationController = BottomSheetNavigationController(rootViewController: viewController, configuration: configuration)
        presentBottomSheet(
            viewController: navigationController,
            configuration: configuration,
            canBeDismissed: canBeDismissed,
            dismissCompletion: dismissCompletion
        )
    }
}
