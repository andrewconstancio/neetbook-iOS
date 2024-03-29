//
//  CurrentUserViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/11/23.
//

import SwiftUI

@MainActor
class CurrentUserViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var username: String = ""
    @Published var photoURL: String = ""
    @Published var profilePicture: UIImage?
    
    
    func loadCurrentUser() async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let dbUser = try await UserManager.shared.getUser(userId: userId)
            
            guard let user = dbUser else {
                throw APIError.invalidData
            }
            
            if let displayname =  user.displayname {
                self.displayName = displayname
            }
            
            if let username =  user.username {
                self.username = username
            }
            
            
            if let photoURL = user.photoUrl {
                let (data, response) = try await Helpers.shared.getDownloadAndResponseDataFromURL(someURL: photoURL)
                let image = Helpers.shared.convertDataToUIImage(data: data, response: response)
                self.profilePicture = image
            }
        } catch {
            throw error
        }
    }
    
    func setCurrentUserPhoto(image: UIImage) {
        self.profilePicture = image
    }
}

