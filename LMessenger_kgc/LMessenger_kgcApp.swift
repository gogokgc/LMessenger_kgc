//
//  LMessenger_kgcApp.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import SwiftUI

@main
struct LMessenger_kgcApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var container: DIContainer = .init(services: Services())
    
    var body: some Scene {
        WindowGroup {
            AuthenticaetdView(authViewModel: .init(container: container))
                .environmentObject(container)
        }
    }
}
