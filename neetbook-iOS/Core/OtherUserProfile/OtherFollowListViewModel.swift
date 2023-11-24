//
//  OtherFollowListViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/20/23.
//

import SwiftUI

@MainActor
class OtherFollowListViewModel: ObservableObject {
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
}
