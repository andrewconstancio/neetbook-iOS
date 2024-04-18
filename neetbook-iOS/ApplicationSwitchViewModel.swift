//
//  ApplicationSwitchViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/12/24.
//

import SwiftUI
import FirebaseAuth

class ApplicationSwitchViewModel: ObservableObject {
    @Published var isLoggedIn = Auth.auth().currentUser != nil
    @Published var accountMade: Bool = false
    
    
    
}
