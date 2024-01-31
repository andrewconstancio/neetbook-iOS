//
//  RootView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    @StateObject private var currentUserViewModel = CurrentUserViewModel()
    @State private var showSignInView: Bool = false
    @State private var showProfileSetUpView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView && !showProfileSetUpView {
                NavigationStack {
                    ContentView(showSignInView: $showSignInView)
                        .environmentObject(currentUserViewModel)
                        .onAppear {
                            Task {
                                try? await currentUserViewModel.loadCurrentUser()
                            }
                        }
                }
                .navigationViewStyle(StackNavigationViewStyle())
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
                self.showSignInView = try await viewModel.checkIfInvalidUser()
                if !self.showSignInView {
                    self.showProfileSetUpView = try await viewModel.checkIfUserAccountMade()
                }
                viewModel.isLoading = false
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
