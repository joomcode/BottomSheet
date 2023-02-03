//
//  UIViewController+CustomInteractiveTransition.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 08.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

public extension UIViewController {
    // MARK: - Public properties

    private(set) var customInteractivePopGestureRecognizer: UIGestureRecognizer? {
        get { objc_getAssociatedObject(self, &Self.gestureRecognizerKey) as? UIGestureRecognizer }
        set { objc_setAssociatedObject(self, &Self.gestureRecognizerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var customInteractivePopTransitioning: UIViewControllerInteractiveTransitioning? { transition }

    // MARK: - Private properties

    private static var gestureRecognizerKey: UInt8 = 0
    private static var gestureRecognizerDelegateKey: UInt8 = 0
    private static var disposableKey: UInt8 = 0
    private static var transitionKey: UInt8 = 0

    private var transition: UIPercentDrivenInteractiveTransition? {
        get { objc_getAssociatedObject(self, &Self.transitionKey) as? UIPercentDrivenInteractiveTransition }
        set { objc_setAssociatedObject(self, &Self.transitionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - Public methods

    func setupCustomInteractivePopTransition() {
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer()
        // TODO: Consider RTL
        gestureRecognizer.edges = .left
        let gestureRecognizerDelegate = GestureRecognizerDelegate(navigationItem: navigationItem)
        gestureRecognizer.delegate = gestureRecognizerDelegate

        if let view = viewIfLoaded {
            view.addGestureRecognizer(gestureRecognizer)
        } else {
            subscribe(onEvent: .viewDidLoad) { [unowned self] in
                view.addGestureRecognizer(gestureRecognizer)
            }
        }

        gestureRecognizer.addTarget(self, action: #selector(handleGestureRecognizer))
        customInteractivePopGestureRecognizer = gestureRecognizer
        objc_setAssociatedObject(self, &Self.gestureRecognizerDelegateKey, gestureRecognizerDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - Private methods

    @objc
    private func handleGestureRecognizer(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .possible:
            break
        case .began:
            processPanGestureBegan(recognizer)
        case .changed:
            processPanGestureChanged(recognizer)
        case .ended:
            processPanGestureEnded(recognizer)
        case .cancelled, .failed:
            processPanGestureCancelled(recognizer)
        @unknown default:
            break
        }
    }

    private func processPanGestureBegan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        transition = UIPercentDrivenInteractiveTransition()
        navigationController?.popViewController(animated: true)
    }

    private func processPanGestureChanged(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        // TODO: Consider RTL
        let progress: CGFloat = translation.x / view.bounds.width
        // TODO: Consider if simulator slow animation is ON
        transition?.update(progress)
    }

    private func processPanGestureEnded(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        let velocity = recognizer.velocity(in: view)
        let translation = recognizer.translation(in: view)

        let deceleration = -copysign(800.0, velocity.x)

        // TODO: Consider RTL
        let finalProgress: CGFloat = (translation.x - 0.5 * velocity.x * velocity.x / deceleration) / view.bounds.width

        let isThresholdPassed = finalProgress < 0.5

        endTransition(isCancelled: isThresholdPassed)
    }

    private func processPanGestureCancelled(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        endTransition(isCancelled: true)
    }

    private func endTransition(isCancelled: Bool) {
        if isCancelled {
            transition?.cancel()
        } else {
            transition?.finish()
        }

        transition = nil
    }
}

private final class GestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    private let navigationItem: UINavigationItem

    init(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        !navigationItem.hidesBackButton
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
