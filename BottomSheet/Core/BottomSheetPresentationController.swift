//
//  BottomSheetPresentationController.swift
//  BottomSheet
//
//  Created by Mikhail Maslo on 05.12.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit

public final class BottomSheetPresentationController: UIPresentationController {
    // MARK: - Nested
    
    private enum State {
        case dismissed
        case presenting
        case presented
        case dismissing
    }
    
    private enum Style {
        static let cornerRadius: CGFloat = 10
        static let pullBarHeight = Style.cornerRadius * 2
    }
    
    // MARK: - Private properties
    
    private var state: State = .dismissed
    
    private var shadingView: UIView?
    private var pullBar: PullBar?
    
    private let dismissalHandler: BottomSheetModalDismissalHandler
    
    // MARK: - Init
    
    public init(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?,
        dismissalHandler: BottomSheetModalDismissalHandler
    ) {
        self.dismissalHandler = dismissalHandler
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    // MARK: - UIPresentationController
    
    public override func presentationTransitionWillBegin() {
        state = .presenting
        
        addSubviews()
        applyStyle()
    }
    
    public override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            state = .presented
        } else {
            state = .dismissed
        }
    }
    
    public override func dismissalTransitionWillBegin() {
        state = .dismissing
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            removeSubviews()
            
            state = .dismissed
        } else {
            state = .presented
        }
    }
    
    public override var shouldPresentInFullscreen: Bool {
        false
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        targetFrameForPresentedView()
    }
    
    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        updatePresentedViewSize()
    }
    
    // MARK: - Private methods
    
    private func applyStyle() {
        guard presentedViewController.isViewLoaded else { return }

        presentedViewController.view.clipsToBounds = true
        presentedViewController.view.layer.cornerRadius = Style.cornerRadius
    }
    
    private func updatePresentedViewSize() {
        guard let presentedView = presentedView else {
            return
        }
        
        let oldFrame = presentedView.frame
        let targetFrame = targetFrameForPresentedView()
        if !oldFrame.isAlmostEqual(to: targetFrame) {
            presentedView.frame = targetFrame
        }
    }
    
    private func targetFrameForPresentedView() -> CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        
        let windowInsets = presentedView?.window?.safeAreaInsets ?? .zero
        
        let preferredHeight = presentedViewController.preferredContentSize.height + windowInsets.bottom
        let maxHeight = containerView.bounds.height - windowInsets.top
        let height = min(preferredHeight, maxHeight)
        
        return .init(
            x: 0,
            y: (containerView.bounds.height - height).pixelCeiled,
            width: containerView.bounds.width,
            height: height.pixelCeiled
        )
    }
    
    private func addSubviews() {
        guard let containerView = containerView else {
            assertionFailure()
            return
        }
        
        setupShadingView(containerView: containerView)
        setupPullBar(containerView: containerView)
    }
    
    private func setupPullBar(containerView: UIView) {
        let pullBar = PullBar()
        pullBar.frame.size = CGSize(width: containerView.frame.width, height: Style.pullBarHeight)
        containerView.addSubview(pullBar)
        
        self.pullBar = pullBar
    }
    
    private func setupShadingView(containerView: UIView) {
        let shadingView = UIView()
        containerView.addSubview(shadingView)
        shadingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        shadingView.frame = containerView.bounds
        
        let tapGesture = UITapGestureRecognizer()
        shadingView.addGestureRecognizer(tapGesture)
        
        tapGesture.addTarget(self, action: #selector(handleShadingViewTapGesture))
        
        self.shadingView = shadingView
    }
    
    @objc
    private func handleShadingViewTapGesture() {
        dismissIfPossible()
    }
    
    private func removeSubviews() {
        shadingView?.removeFromSuperview()
        shadingView = nil
        pullBar?.removeFromSuperview()
        pullBar = nil
    }
    
    @discardableResult
    private func dismissIfPossible() -> Bool {
        let canBeDismissed = state == .presented
        
        if canBeDismissed {
            dismissalHandler.performDismissal(animated: true)
        }
        
        return canBeDismissed
    }
}

extension BottomSheetPresentationController: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let sourceViewController = transitionContext.viewController(forKey: .from),
            let destinationViewController = transitionContext.viewController(forKey: .to),
            let sourceView = sourceViewController.view,
            let destinationView = destinationViewController.view
        else {
            return
        }
        
        let isPresenting = destinationViewController.isBeingPresented
        let presentedView = isPresenting ? destinationView : sourceView
        let containerView = transitionContext.containerView
        if isPresenting {
            containerView.addSubview(destinationView)
            
            destinationView.frame = containerView.bounds
        }
        
        sourceView.layoutIfNeeded()
        destinationView.layoutIfNeeded()
        
        let frameInContainer = frameOfPresentedViewInContainerView
        let offscreenFrame = CGRect(
            origin: CGPoint(
                x: 0,
                y: containerView.bounds.height
            ),
            size: sourceView.frame.size
        )
        
        presentedView.frame = isPresenting ? offscreenFrame : frameInContainer
        pullBar?.frame.origin.y = presentedView.frame.minY - Style.pullBarHeight + pixelSize
        shadingView?.alpha = isPresenting ? 0 : 1
        
        let animations = {
            presentedView.frame = isPresenting ? frameInContainer : offscreenFrame
            self.pullBar?.frame.origin.y = presentedView.frame.minY - Style.pullBarHeight + pixelSize
            self.shadingView?.alpha = isPresenting ? 1 : 0
        }
        
        let completion = { (completed: Bool) in
            transitionContext.completeTransition(completed && !transitionContext.transitionWasCancelled)
        }
        
        let options: UIView.AnimationOptions = transitionContext.isInteractive ? .curveLinear : .curveEaseInOut
        let transitionDurationValue = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: transitionDurationValue, delay: 0, options: options, animations: animations, completion: completion)
    }
}
