//
//  BottomSheetNavigationController.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 08.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

public final class BottomSheetNavigationController: UINavigationController {
    // MARK: - Private properties

    private var isUpdatingNavigationStack = false

    private var canAnimatePreferredContentSizeUpdates = false

    private weak var lastTransitionViewController: UIViewController?

    private let configuration: BottomSheetConfiguration

    // MARK: - Init

    public init(rootViewController: UIViewController, configuration: BottomSheetConfiguration) {
        self.configuration = configuration
        super.init(rootViewController: rootViewController)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        view.clipsToBounds = true
        view.backgroundColor = .white.withAlphaComponent(0.6)

        modalPresentationStyle = .custom
    }

    // MARK: - UINavigationController

    public override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        updateNavigationStack(animated: animated) {
            super.setViewControllers(viewControllers, animated: animated)
        }
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        updateNavigationStack(animated: animated) {
            super.pushViewController(viewController, animated: animated)
        }
    }

    public override func popViewController(animated: Bool) -> UIViewController? {
        var viewController: UIViewController?

        updateNavigationStack(animated: animated) {
            viewController = super.popViewController(animated: animated)
        }

        return viewController
    }

    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        var viewControllers: [UIViewController]?

        updateNavigationStack(animated: animated) {
            viewControllers = super.popToRootViewController(animated: animated)
        }

        return viewControllers
    }

    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        guard
            let viewController = container as? UIViewController,
            viewController === topViewController,
            !isUpdatingNavigationStack
        else { return }

        let updates = { [self] in
            updatePreferredContentSize()
            view.layoutIfNeeded()
        }

        if canAnimatePreferredContentSizeUpdates {
            UIView.animate(withDuration: 0.25, animations: updates)
        } else {
            updates()
        }

        canAnimatePreferredContentSizeUpdates = true
    }

    // MARK: - Private methods

    private func updateNavigationStack(animated: Bool, applyChanges: () -> Void) {
        isUpdatingNavigationStack = true

        applyChanges()

        if let transitionCoordinator = transitionCoordinator, animated, transitionCoordinator.isAnimated {
            transitionCoordinator.animate(
                alongsideTransition: { _ in
                    self.updatePreferredContentSize()
                },
                completion: { context in
                    self.isUpdatingNavigationStack = false
                    self.updatePreferredContentSize()
                }
            )
        } else {
            isUpdatingNavigationStack = false
            updatePreferredContentSize()
        }
    }

    private func updatePreferredContentSize() {
        preferredContentSize = CGSize(
            width: view.bounds.width,
            height: topViewController?.preferredContentSize.height ?? 0 + additionalSafeAreaInsets.top + additionalSafeAreaInsets.bottom
        )
    }
}

extension BottomSheetNavigationController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            toVC.setupCustomInteractivePopTransition()
        }

        lastTransitionViewController = fromVC
        return BottomSheetNavigationAnimatedTransitioning(operation: operation, configuration: configuration)
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        lastTransitionViewController?.customInteractivePopTransitioning
    }
}
