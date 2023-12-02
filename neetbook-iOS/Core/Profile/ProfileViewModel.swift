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
    @Published var activity: [PostFeedInstance] = []
    @Published var photoURL: String = ""
    @Published var followingCount = 0
    @Published var followerCount = 0
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        followingCount = try await UserManager.shared.getFollowingCount(userId: authDataResult.uid)
        followerCount = try await UserManager.shared.getFollowerCount(userId: authDataResult.uid)
        try await self.getUserActivity(userId: authDataResult.uid)
    }
    
    func getUserActivity(userId: String) async throws {
        do {
            self.activity = try await UserFeedManager.shared.getUserActivty(userId: userId)
        } catch {
            throw error
        }
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
