//
//  HomeViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/23.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var photoURL: String = ""
    @Published var post: [PostFeedInstance] = []
    @Published var isLoadingFeed: Bool = false
    
    func getProfileURL() async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let photoURL = try await UserManager.shared.getProfileProfileImageUrl(userId: userId)
            self.photoURL = photoURL
        } catch {
            throw error
        }
    }
    
    func getHomeFeed() async throws {
        do {
            isLoadingFeed = true
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            self.post = try await UserFeedManager.shared.getUserHomeFeed(userId: userId)
            isLoadingFeed = false
        } catch {
            throw error
        }
    }
}
