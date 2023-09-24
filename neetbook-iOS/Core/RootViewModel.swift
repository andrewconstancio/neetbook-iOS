//
//  RootViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI

final class RootViewModel: ObservableObject {
    @Published var isLoading = false
    
    func checkIfInvalidUser() async throws -> Bool {
        let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
        if authUser != nil {
            let dbUser = try? await UserManager.shared.getUser(userId: authUser?.uid ?? "")
            return dbUser == nil
        }
        
        return true
    }
}
