//
//  FollowListViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/19/23.
//

import SwiftUI

struct FollowingUser: Identifiable, Hashable {
    let id = UUID()
    let userId: String
    let displayName: String
    let username: String
    let hashcode: String
    let profileImage: UIImage?
    var followingStatus: FollowingStatus
    
    mutating func setFollowStatus(value: FollowingStatus) {
        self.followingStatus = value
    }
}

struct FollowerUser: Identifiable, Hashable {
    let id = UUID()
    let userId: String
    let displayName: String
    let username: String
    let hashcode: String
    let profileImage: UIImage?
}

@MainActor
class FollowListViewModel: ObservableObject {
    @Published var following: [FollowingUser] = []
    @Published var followers: [FollowerUser] = []
    @Published var isLoadingFollowers: Bool = false
    
    func getAllFollowData(userId: String) async throws {
        do {
            isLoadingFollowers = true
            try await getFollowingUsers(userId: userId)
            try await getFollowerUsers(userId: userId)
            isLoadingFollowers = false
        } catch {
            throw error
        }
    }
    
    func getFollowingUsers(userId: String) async throws {
        following = try await UserManager.shared.getUserFollowing(userId: userId)
    }
    
    func getFollowerUsers(userId: String) async throws {
        followers = try await UserManager.shared.getUserFollowers(userId: userId)
    }
    
    func unfollowUser(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.unfollowUser(currentUserId: currentUserId, userId: userId)
        } catch {
            throw error
        }
    }
    
    func requestToFollow(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.requestToFollow(currentUserId: currentUserId, userId: userId)
        } catch {
            throw error
        }
    }
    
    func deleteFollowRequest(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.deleteUserFollowRequest(currentUserId: currentUserId, userId: userId)
        } catch {
            throw error
        }
    }
    
    func removeFollower(userId: String, instanceId: UUID) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.removeFollower(currentUserId: currentUserId, userId: userId)
            followers = followers.filter { $0.id != instanceId}
        } catch {
            throw error
        }
    }
}
