//
//  RootViewController.swift
//  BottomSheetDemo
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit
import SnapKit
import BottomSheet

final class RootViewController: UIViewController {
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Show Bottom Sheet", for: .normal)
        return button
    }()
    
    private var bottomSheetTransitioningDelegate: UIViewControllerTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.addSubview(button)
        button.addTarget(self, action: #selector(handleShowBottomSheet), for: .touchUpInside)
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(44)
        }
    }
    
    @objc
    private func handleShowBottomSheet() {
        let viewController = ResizeViewController(initialHeight: 300)
        bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(factory: self)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = bottomSheetTransitioningDelegate
        present(viewController, animated: true, completion: nil)
    }
}

extension RootViewController: BottomSheetPresentationControllerFactory {
    func makeBottomSheetPresentationController(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?
    ) -> BottomSheetPresentationController {
        .init(
            presentedViewController: presentedViewController,
            presentingViewController: presentingViewController,
            dismissalHandler: self
        )
    }
}

extension RootViewController: BottomSheetModalDismissalHandler {
    func performDismissal(animated: Bool) {
        presentedViewController?.dismiss(animated: animated, completion: nil)
    }
}
