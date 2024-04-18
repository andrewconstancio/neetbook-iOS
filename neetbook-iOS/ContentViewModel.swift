//
//  ContentViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/6/24.
//

import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    @Published private(set) var pendingFriendCount: Int = 0

    func getPendingFriendsCount() async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        pendingFriendCount = try await UserInteractions.shared.getPendingFriendsCount(userId: currentUserId)
    }
}
