//
//  CurrentUserViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/11/23.
//

import SwiftUI

@MainActor
class CurrentUserViewModel: ObservableObject {
    @Published var user: DBUser? = nil
    
    func fetchUser() async throws {
        let userId = try? AuthenticationManager.shared.getAuthenticatedUserUserId()
        let user = try? await UserManager.shared.getUser(userId: userId ?? "")
        
        guard var user = user, let photoURL = user.photoUrl else {
            throw APIError.invalidData
        }
        
        // set profile photo
        let image = try await UserManager.shared.getURLImageAsUIImage(path: photoURL)
        user.setUserProfilePic(image: image)
    
        self.user = user
    }
}

