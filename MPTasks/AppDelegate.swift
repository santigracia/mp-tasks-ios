//
//  AppDelegate.swift
//  MPTasks
//
//  Created by Santi Gracia on 3/24/20.
//  Copyright © 2020 Mixpanel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")

        self.window?.rootViewController = navigationController
        
        navigationController.pushViewController(initialViewController, animated: false)
        self.window?.makeKeyAndVisible()
        
        return true
    }

}

