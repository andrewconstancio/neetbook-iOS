//
//  NotificationsViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/19/23.
//

import SwiftUI


enum NotificationAction {
    case follewRequest
}

struct Notification: Identifiable, Hashable {
    let id = UUID()
    let userId: String
    let displayName: String
    let username: String
    let hashcode: String
    let profileImage: UIImage?
    let action: NotificationAction?
}


@MainActor
class NotificationsViewModel: ObservableObject {
    @Published private(set) var notifications: [Notification] = []
    
    func getUserNotifications() async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        self.notifications = try await UserInteractions.shared.getUserNotifications(currentUserId: currentUserId)
    }
    
    func confirmFollowRequest(userId: String, notiId: UUID) async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        try await UserInteractions.shared.confirmUserFollowRequest(currentUserId: currentUserId, userId: userId)
        notifications = notifications.filter { $0.id != notiId}
    }
    
    func deleteFollowRequest(userId: String, notiId: UUID) async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        try await UserInteractions.shared.deleteUserFollowRequest(currentUserId: currentUserId, userId: userId)
        notifications = notifications.filter { $0.id != notiId}
    }
}
