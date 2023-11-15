//
//  ProfileViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/15/23.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published var favoriteBooks: [FavoriteBook] = []
    @Published var photoURL: String = ""
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func getFavoriteBooks() async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            self.favoriteBooks = try await BookUserManager.shared.getFavoriteBooks(userId: userId)
        } catch {
            throw error
        }
    }
    
    func getPhotoURL() async throws {
//        do {
//            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
//            let photoURL = try await UserManager.shared.getProfileProfileImageUrl(userId: userId)
//            self.photoURL = photoURL
//        } catch {
//            throw error
//        }
    }
}
