//
//  AuthenticationViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/9/23.
//

import SwiftUI
import AuthenticationServices

enum AuthSignInMethods {
    case google, apple
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    @Published var didSignInWithApple: Bool = false

    func signInGoogle() async throws -> AuthDataResultModel {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResults = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
        
        return authDataResults
    }
    
    func signInApple() async throws -> AuthDataResultModel {
        let helper = SignInWithAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResults = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
        
        return authDataResults
    }
    
    func signInDevTestUser() async throws -> AuthDataResultModel {
        let authDataResults = try await AuthenticationManager.shared.signInDevTestingUser()
        
        return authDataResults
    }
    
    func checkUserAccountCreated(userId: String) async throws -> Bool {
        return try await UserManager.shared.checkUserExist(userId: userId)
    }
    
    func signInUserFlow(signInMethod: AuthSignInMethods) async throws -> Bool {
        let profileSetup: Bool
        let authDataResults: AuthDataResultModel
        
        switch(signInMethod) {
        case.google:
            authDataResults = try await signInGoogle()
        case .apple:
            authDataResults = try await signInApple()
        }

        let userAcountCreated = try await checkUserAccountCreated(userId: authDataResults.uid)
          
        return userAcountCreated
    }
}
 
