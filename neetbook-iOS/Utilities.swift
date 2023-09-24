//
//  Utilities.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/8/23.
//

import UIKit

final class Utilities {
    
    static let shared = Utilities()
    
    private init() {}
    
    @MainActor
    func getTopViewController(base: UIViewController? = nil) -> UIViewController? {
        
        let base = base ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
}
