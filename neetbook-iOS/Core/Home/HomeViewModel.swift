//
//  HomeViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/23.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var photoURL: String = ""
    
    
    func getProfileURL() async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let photoURL = try await UserManager.shared.getProfileProfileImageUrl(userId: userId)
            self.photoURL = photoURL
        } catch {
            throw error
        }
    }
}
