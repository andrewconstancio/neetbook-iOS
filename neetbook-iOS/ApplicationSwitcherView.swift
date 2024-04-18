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
//        ZStack {
//            switch userStateViewModel.userState {
//            case .isLoading:
//                LogoView()
//            case .loggedOut:
//                AuthenticationView()
//                    .environmentObject(userStateViewModel)
//            case .accountNotMade:
//                ProfileSetupRootView()
//                    .environmentObject(userStateViewModel)
//            case .loggedIn:
//                ContentView()
//                    .environmentObject(userStateViewModel)
//            }
//        }
//        .task {
//            await userStateViewModel.initFlow()
//        }
    }
}

#Preview {
    ApplicationSwitcherView()
}
