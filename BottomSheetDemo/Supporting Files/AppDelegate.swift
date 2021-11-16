//
//  AppDelegate.swift
//  BottomSheetDemo
//
//  Created by Mikhail Maslo on 14.11.2021.
//  Copyright © 2021 Joom. All rights reserved.
//

import UIKit
import BottomSheet

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupWindow()
        invokeLoad()
        
        return true
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
    }
    
    private func invokeLoad() {
        UIViewController.swiftLoad()
    }
}
