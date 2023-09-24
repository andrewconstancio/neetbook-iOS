//
//  RootView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    @State private var showSignInView: Bool = true
    @State private var showProfileSetUpView: Bool = true
    
    var body: some View {
        ZStack {
            if !showSignInView && !showProfileSetUpView {
                NavigationView {
                    ContentView(showSignInView: $showSignInView)
                }
            }
            
            if viewModel.isLoading {
                LogoView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if showSignInView {
                NavigationView {
                    AuthenticationView(showSignInView: $showSignInView, showProfileSetUpView: $showProfileSetUpView)
                }
            } else if showProfileSetUpView {
                ProfileSetupRootView(showProfileSetUpView: $showProfileSetUpView)
            }
        }
        .onAppear {
            Task {
                viewModel.isLoading = true
                let result = try await viewModel.checkIfInvalidUser()
                viewModel.isLoading = false
                (self.showSignInView, self.showProfileSetUpView) = (result, result)
            }
        }
//        .fullScreenCover(isPresented: $showSignInView) {
//            NavigationView {
//                AuthenticationView(showSignInView: $showSignInView, showProfileSetUpView: $showProfileSetUpView)
//            }
//        }
//        .fullScreenCover(isPresented: $showProfileSetUpView) {
//            NavigationView {
//                ProfileSetupRootView(showProfileSetUpView: $showProfileSetUpView)
//            }
//        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
