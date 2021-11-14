//
//  RootViewController.swift
//  BottomSheetDemo
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit
import SnapKit

final class RootViewController: UIViewController {
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("Show BottomSheet", for: .normal)
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.backgroundColor = .red
        
        button.addTarget(self, action: #selector(handleShowBottomSheet), for: .touchUpInside)
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(44)
        }
    }
    
    @objc
    private func handleShowBottomSheet() {
        // TODO: Implement
    }
}
