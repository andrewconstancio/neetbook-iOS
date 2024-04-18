//
//  PendingFriendsViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/5/24.
//

import SwiftUI

enum NotificationAction {
    case follewRequest
    case followRequestAccepted
}

struct FollowRequest: Identifiable, Hashable {
    let id = UUID()
    let userId: String
    let displayName: String
    let username: String
    let hashcode: String
    let profileImage: UIImage?
    let action: NotificationAction?
}


@MainActor
class PendingFriendsViewModel: ObservableObject {
    @Published private(set) var followRequest: [FollowRequest] = []
    @Published private(set) var isLoading: Bool = false
    
    init() {
        Task {
            try await setup()
        }
    }
    
    func setup() async throws {
        isLoading = true
        try await getUserFollowRequest()
        isLoading = false
    }
    
    func getUserFollowRequest() async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        self.followRequest = try await UserInteractions.shared.getUserFollowRequest(currentUserId: currentUserId)
    }
    
    func confirmFollowRequest(userId: String, notiId: UUID) async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        try await UserInteractions.shared.confirmUserFollowRequest(currentUserId: currentUserId, userId: userId)
        followRequest = followRequest.filter { $0.id != notiId}
    }
    
    func deleteFollowRequest(userId: String, notiId: UUID) async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        try await UserInteractions.shared.deleteUserFollowRequest(currentUserId: currentUserId, userId: userId)
        followRequest = followRequest.filter { $0.id != notiId}
    }
}
