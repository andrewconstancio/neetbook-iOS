//
//  ProfileViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/15/23.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var currUserID: String = ""
    @Published var isLoadingMainData: Bool = false
    @Published var isLoadingActivity: Bool = false
    @Published var favoriteBooks: [FavoriteBook] = []
    @Published var activity: [PostFeedInstance] = []
    @Published var photoURL: String = ""
    @Published var followingCount = 0
    @Published var followerCount = 0
    @Published var userUpdated: Bool = false
    @Published var followingStatus: FollowingStatus = .notFollowing
    @Published var activityCount: Int = 0
    @Published var finishedBooks: [MarkedBook] = []
    
    var activitiesLastDocument: DocumentSnapshot? = nil
    
    private var bookUserActionManager = BookUserActionManager()
    
    init(userId: String) {
        Task {
            isLoadingMainData = true
            try? await fetchUser(userId: userId)
            try? await getUserActivity(userId: userId)
            try? await getFavoriteBooks(userId: userId)
            try? await getUserFollowingCount(userId: userId)
            try? await getUserFollowerCount(userId: userId)
            
            if let user = user {
                if !user.isCurrentUser {
                    try await checkUserFollowing(userId: userId)
                }
            }
            isLoadingMainData = false
        }
    }
    
    func fetchUser(userId: String) async throws {
        let user = try? await UserManager.shared.getUser(userId: userId)
        
        guard var user = user, let photoURL = user.photoUrl else {
            throw APIError.invalidData
        }
        
        // set profile photo
        let image = try await UserManager.shared.getURLImageAsUIImage(path: photoURL)
        user.setUserProfilePic(image: image)
        self.user = user
    }
        
    func getUserFollowingCount(userId: String) async throws {
        do {
            followingCount = try await UserManager.shared.getFollowingCount(userId: userId)
        } catch {
            throw error
        }
    }
    
    func getUserFollowerCount(userId: String) async throws {
        do {
            followerCount = try await UserManager.shared.getFollowerCount(userId: userId)
        } catch {
            throw error
        }
    }
    
    func getUserActivity(userId: String) async throws {
        do {
            let (activities, lastDocument) = try await UserFeedManager.shared.getUserActivities(userId: userId, lastDocument: activitiesLastDocument)
            
            activity.append(contentsOf: activities)
//            self.activityCount = self.activity.count
            activitiesLastDocument = lastDocument
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
    
    func checkUserFollowing(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let result =  try await UserInteractions.shared.checkUserFollowing(currentUserId: currentUserId, userId: userId)
            if result {
                followingStatus = .following
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
            followingStatus = reseult ? .requestedToFollow : followingStatus
        } catch {
            throw error
        }
    }
    
    func requestToFollow(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.requestToFollow(currentUserId: currentUserId, userId: userId)
            followingStatus = .requestedToFollow
        } catch {
            throw error
        }
    }
    
    func unfollowUser(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.unfollowUser(currentUserId: currentUserId, userId: userId)
            followingStatus = .notFollowing
            followerCount -= 1
        } catch {
            throw error
        }
    }
    
    func deleteFollowRequest(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.deleteUserFollowRequest(currentUserId: currentUserId, userId: userId)
            followingStatus = .notFollowing
        } catch {
            throw error
        }
    }
    
    func getFinishedBooks() async throws {
        if let userId = user?.userId {
            finishedBooks = try await bookUserActionManager.getMarkedBookTypesForUser(userId: userId, markedType: .finished)
        }
    }
}
