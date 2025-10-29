//
//  ApplicationSwitcherView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/13/24.
//

import SwiftUI
import FirebaseAuth

struct ApplicationSwitcherView: View {
    @State private var isLoggedIn = Auth.auth().currentUser != nil
    
    var body: some View {
        ZStack {
            if isLoggedIn {
                ContentView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
             Auth.auth().addStateDidChangeListener { auth, user in
                 isLoggedIn = user != nil
             }
         }
    }
}

#Preview {
    ApplicationSwitcherView()
}
