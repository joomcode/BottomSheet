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
    
    var isShowNextButtonHidden: Bool {
        navigationController == nil
    }
    
    var isShowRootButtonHidden: Bool {
        navigationController?.viewControllers.count ?? 0 <= 1
    }
    
    private let showNextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Show next", for: .normal)
        return button
    }()
    
    private let showRootButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.setTitle("Show root", for: .normal)
        return button
    }()
    
    private let _scrollView = UIScrollView()
    private let scrollContentView = UIView()
    
    // MARK: - Private properties
    
    private lazy var actions = [
        ButtonAction(title: "x2", backgroundColor: .systemBlue, handler: { [unowned self] in
            updateContentHeight(newValue: currentHeight * 2)
        }),
        ButtonAction(title: "/2", backgroundColor: .systemBlue, handler: { [unowned self] in
            updateContentHeight(newValue: currentHeight / 2)
        }),
        ButtonAction(title: "+100", backgroundColor: .systemBlue, handler: { [unowned self] in
            updateContentHeight(newValue: currentHeight + 100)
        }),
        ButtonAction(title: "-100", backgroundColor: .systemBlue, handler: { [unowned self] in
            updateContentHeight(newValue: currentHeight - 100)
        }),
    ]
    
    private var currentHeight: CGFloat
    
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
        updateContentHeight(newValue: currentHeight)
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        view.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1)
        
        view.addSubview(_scrollView)
        _scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        _scrollView.addSubview(scrollContentView)
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(currentHeight)
        }
        
        scrollContentView.addSubview(contentSizeLabel)
        contentSizeLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        let buttons = actions.map(UIButton.init(buttonAction:))
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        scrollContentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(contentSizeLabel.snp.bottom).offset(8)
            $0.width.equalToSuperview().offset(-32)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        if !isShowNextButtonHidden {
            _scrollView.addSubview(showNextButton)
            showNextButton.addTarget(self, action: #selector(handleShowNext), for: .touchUpInside)
            showNextButton.snp.makeConstraints {
                $0.top.equalTo(stackView.snp.bottom).offset(8)
                $0.centerX.equalTo(stackView)
                $0.width.equalTo(300)
                $0.height.equalTo(50)
            }
        }
        
        if !isShowRootButtonHidden {
            _scrollView.addSubview(showRootButton)
            showRootButton.addTarget(self, action: #selector(handleShowRoot), for: .touchUpInside)
            showRootButton.snp.makeConstraints {
                $0.top.equalTo(isShowNextButtonHidden ? stackView.snp.bottom : showNextButton.snp.bottom).offset(8)
                $0.centerX.equalTo(stackView)
                $0.width.equalTo(300)
                $0.height.equalTo(50)
            }
        }
    }
    
    // MARK: - Private methods
    
    @objc
    private func handleShowNext() {
        let viewController = ResizeViewController(initialHeight: currentHeight)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func handleShowRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func updateContentHeight(newValue: CGFloat) {
        guard newValue >= 200 && newValue < 5000 else { return }
        
        contentSizeLabel.text = "preferredContentHeight = \(newValue)"
        currentHeight = newValue
        
        let updates = { [self] in
            scrollContentView.snp.updateConstraints {
                $0.height.equalTo(newValue)
            }
            preferredContentSize = CGSize(
                width: UIScreen.main.bounds.width,
                height: newValue
            )
        }
        let canAnimateChanges = viewIfLoaded?.window != nil
        if canAnimateChanges {
            UIView.animate(withDuration: 0.25, animations: updates)
        } else {
            updates()
        }
    }
}

extension ResizeViewController: ScrollableBottomSheetPresentedController {
    var scrollView: UIScrollView? {
        _scrollView
    }
}
