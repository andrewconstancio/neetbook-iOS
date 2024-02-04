//
//  HomeViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/23.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
    @Published var photoURL: String = ""
    @Published var post: [PostFeedInstance] = []
    @Published var isLoadingFeed: Bool = false
    var lastDocument: DocumentSnapshot? = nil
    
    init() {
        Task {
            self.isLoadingFeed = true
            try? await self.getHomeFeed()
            self.isLoadingFeed = false
        }
    }
    
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
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let (post, lastDocument) = try await UserFeedManager.shared.getUserHomeFeed(userId: userId, lastDocument: lastDocument)
            self.post.append(contentsOf: post)
            self.lastDocument = lastDocument
        } catch {
            throw error
        }
    }
}
