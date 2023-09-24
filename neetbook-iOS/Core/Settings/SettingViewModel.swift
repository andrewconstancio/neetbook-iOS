//
//  SettingViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/9/23.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
    
    func resetPassword( ) async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPasswordEmail(email: email)
    }
    
    func updatePassword() async throws {
        try await AuthenticationManager.shared.updatePassword(password: "helo234")
    }
    
    func updateEmail() async throws {
        try await AuthenticationManager.shared.updateEmail(email: "andrew@testing.com")
    }
}
