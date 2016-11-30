//
//  AppDelegate.swift
//  Commute
//
//  Created by Boris Yurkevich on 27/11/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataManager = CoreDataManager.sharedInstance


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataManager.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataManager.saveContext()
    }
}

