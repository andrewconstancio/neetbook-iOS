//
//  NotificationsViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/19/23.
//

import SwiftUI



@MainActor
class NotificationsViewModel: ObservableObject {
    @Published  var notifications: [UserNotification] = []
    @Published private(set) var pendingFriendCount: Int = 0
    
    func getPendingFriendsCount(userId: String) async throws {
        pendingFriendCount = try await UserInteractions.shared.getPendingFriendsCount(userId: userId)
    }
    
    func getNotifications(userId: String) async throws {
        notifications = try await UserInteractions.shared.getUserNotifications(userId: userId)
    }
    
    func requestToFollow(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.requestToFollow(currentUserId: currentUserId, userId: userId)
        } catch {
            throw error
        }
    }
    
    func unfollowUser(userId: String) async throws {
        do {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await UserInteractions.shared.unfollowUser(currentUserId: currentUserId, userId: userId)
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
    
    func confirmFollowRequest(userId: String, notiId: UUID) async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        try await UserInteractions.shared.confirmUserFollowRequest(currentUserId: currentUserId, userId: userId)
    }
    
    func deleteFollowRequest(userId: String, notiId: UUID) async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        try await UserInteractions.shared.deleteUserFollowRequest(currentUserId: currentUserId, userId: userId)
        notifications = notifications.filter { $0.id != notiId}
    }
}
