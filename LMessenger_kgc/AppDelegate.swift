//
//  AppDelegate.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/4/24.
//

import UIKit
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
