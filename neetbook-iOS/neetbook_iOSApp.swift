//
//  neetbook_iOSApp.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth

@main
struct neetbook_iOSApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delgate
    
    var body: some Scene {
        WindowGroup {
            ApplicationSwitcherView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

