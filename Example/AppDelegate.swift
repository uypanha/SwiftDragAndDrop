//
//  AppDelegate.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/6/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let navController = UINavigationController()
        let viewController = RootViewController()
        navController.pushViewController(viewController, animated: false)
        window?.rootViewController = navController
        
        return true
    }
    
}

