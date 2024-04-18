//
//  OtherUserProfileViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/14/23.
//

import SwiftUI



@MainActor
class OtherUserProfileViewModel: ObservableObject {
    @Published var mainDataLoading: Bool = true
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var userProfilePicture: UIImage?
    @Published private(set) var userDataLoading: Bool = false
    @Published var activity: [PostFeedInstance] = []
    @Published var favoriteBooks: [FavoriteBook] = []
    @Published var followingStatus: FollowingStatus = .notFollowing
    @Published var followingCount = 0
    @Published var followerCount = 0
    
    func loadInitialUserData(userId: String) async throws {
        self.mainDataLoading = true
        try await getUserData(userId: userId)
        try await checkUserFollowing(userId: userId)
        try await getFavoriteBooks(userId: userId)
        try await getUserActivity(userId: userId)
        self.mainDataLoading = false
    }
    
    func getUserData(userId: String) async throws {
        self.user = try await UserManager.shared.getUser(userId: userId)
        
        if let photoUrl = user?.photoUrl {
            userDataLoading = true
            let image = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
            self.userProfilePicture = image
            userDataLoading = false
        }
        
        followingCount = try await UserManager.shared.getFollowingCount(userId: userId)
        followerCount = try await UserManager.shared.getFollowerCount(userId: userId)
    }
    
    func checkUserFollowing(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let result =  try await UserInteractions.shared.checkUserFollowing(currentUserId: currentUserId, userId: userId)
            if result {
                self.followingStatus = .following
            } else {
                try await checkUserFollowRequest(userId: userId)
            }
        } catch {
            throw error
        }
    }
    
    func checkUserFollowRequest(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let reseult =  try await UserInteractions.shared.checkUserFollowRequest(currentUserId: currentUserId, userId: userId)
            self.followingStatus = reseult ? .requestedToFollow : self.followingStatus
        } catch {
            throw error
        }
    }
    
    func getFavoriteBooks(userId: String) async throws {
        do {
            self.favoriteBooks = try await BookUserManager.shared.getFavoriteBooks(userId: userId)
        } catch {
            throw error
        }
    }
    
    func requestToFollow(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.requestToFollow(currentUserId: currentUserId, userId: userId)
            self.followingStatus = .requestedToFollow
        } catch {
            throw error
        }
    }
    
    func unfollowUser(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.unfollowUser(currentUserId: currentUserId, userId: userId)
            self.followingStatus = .notFollowing
            self.followerCount -= 1
        } catch {
            throw error
        }
    }
    
    func deleteFollowRequest(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.deleteUserFollowRequest(currentUserId: currentUserId, userId: userId)
            self.followingStatus = .notFollowing
        } catch {
            throw error
        }
    }
    
    func getUserActivity(userId: String) async throws {
        do {
            self.activity = try await UserFeedManager.shared.getUserActivty(userId: userId)
        } catch {
            throw error
        }
    }
}
