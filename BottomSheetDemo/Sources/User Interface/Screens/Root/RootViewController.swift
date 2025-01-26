//
//  RootViewController.swift
//  BottomSheetDemo
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import BottomSheet
import SnapKit
import UIKit

final class RootViewController: UIViewController {
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Show BottomSheet", for: .normal)
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        showBottomSheetWithoutScrollView()
        /*
         let viewController = ResizeViewController(initialHeight: 300)
         presentBottomSheetInsideNavigationController(
             viewController: viewController,
             configuration: .default,
             canBeDismissed: {
                 // return `true` or `false` based on your business logic
                 true
             },
             dismissCompletion: {
                 // handle bottom sheet dismissal completion
             }
         )
          */
    }

    private func showBottomSheetWithoutScrollView() {
        let viewController = ViewControllerWithoutScrollView(nibName: nil, bundle: nil)
        presentBottomSheet(viewController: viewController, configuration: .default)
    }
}

final class ViewControllerWithoutScrollView: UIViewController {
    private let contentView = UIView()
    private lazy var label1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = """
        [Label 1]
        Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
        """
        return label
    }()

    private lazy var label2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = """
        [Label 2]
        Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
        """
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupSubviews()
    }

    private func setupSubviews() {
        view.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        // put any subviews you want
        // contentView size should be a sum of all sizes (via constraints / manually)
        contentView.addSubview(label1)
        contentView.addSubview(label2)

        label1.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }

        label2.snp.makeConstraints { make in
            make.top.equalTo(label1.snp.bottom).offset(100)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        preferredContentSize = contentView.frame.size
    }
}
