//
//  ResizeViewController.swift
//  BottomSheetDemo
//
//  Created by Mikhail Maslo on 15.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit
import BottomSheet

final class ResizeViewController: UIViewController {
    // MARK: - Subviewss
    
    private let contentSizeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let _scrollView = UIScrollView()
    
    // MARK: - Private properties

    private lazy var actions = [
        UIAction(title: "x2", handler: { [unowned self] _ in
            updateContentHeight(newValue: currentHeight * 2)
        }),
        UIAction(title: "/2", handler: { [unowned self] _ in
            updateContentHeight(newValue: currentHeight / 2)
        }),
        UIAction(title: "+100", handler: { [unowned self] _ in
            updateContentHeight(newValue: currentHeight + 100)
        }),
        UIAction(title: "-100", handler: { [unowned self] _ in
            updateContentHeight(newValue: currentHeight - 100)
        })
    ]
    
    private var currentHeight: CGFloat {
        didSet {
            updatePreferredContentSize()
        }
    }
    
    // MARK: - Init

    init(initialHeight: CGFloat) {
        currentHeight = initialHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewCoontroller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        updatePreferredContentSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.setNeedsLayout()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        view.backgroundColor = .white
        
        view.addSubview(_scrollView)
        _scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        _scrollView.alwaysBounceVertical = true
        
        _scrollView.addSubview(contentSizeLabel)
        contentSizeLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        let buttons = actions.map { action -> UIButton in
            let button = UIButton(primaryAction: action)
            button.backgroundColor = .blue
            button.setTitleColor(.white, for: .normal)
            return button
        }
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        _scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(contentSizeLabel.snp.bottom).offset(8)
            $0.width.equalTo(view)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    // MARK: - Private methods
    
    private func updatePreferredContentSize() {
        _scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: currentHeight)
        contentSizeLabel.text = "preferredContentHeight = \(currentHeight)"
        preferredContentSize = _scrollView.contentSize
    }
    
    private func updateContentHeight(newValue: CGFloat) {
        guard newValue > 0 && newValue < 5000 else { return }
        
        currentHeight = newValue
        updatePreferredContentSize()
    }
}

// MARK: - ScrollableBottomSheetPresentedController

extension ResizeViewController: ScrollableBottomSheetPresentedController {
    var scrollView: UIScrollView? {
        _scrollView
    }
}
