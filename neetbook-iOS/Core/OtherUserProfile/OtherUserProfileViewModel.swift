//
//  OtherUserProfileViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/14/23.
//

import SwiftUI

@MainActor
class OtherUserProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var userProfilePicture: UIImage?
    @Published private(set) var userDataLoading: Bool = false
    
    func getUserData(userId: String) async throws {
        self.user = try await UserManager.shared.getUser(userId: userId)
        
        if let photoUrl = user?.photoUrl {
            userDataLoading = true
            let image = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
            self.userProfilePicture = image
            userDataLoading = false
        }
    }
}
