//
//  FeedViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/7/24.
//


import SwiftUI
import FirebaseFirestore

@MainActor
class FeedViewModel: ObservableObject {
    @Published var photoURL: String = ""
    @Published var post: [PostFeedInstance] = []
    @Published var isLoadingFeed: Bool = false
    var lastDocument: DocumentSnapshot? = nil
    
    init() {
        Task {
            isLoadingFeed = true
            try? await getFeed()
            isLoadingFeed = false
        }
    }
    
    
    func getFeed() async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let (postReturn, lastDocumentReturn) = try await UserFeedManager.shared.getUserHomeFeed(userId: userId, lastDocument: lastDocument)
            
            DispatchQueue.main.async {
                self.post.append(contentsOf: postReturn)
                self.lastDocument = lastDocumentReturn
            }
        } catch {
            throw error
        }
    }
    
    func refreshFeed() async throws {
        if let firstDocumentId = post.first?.documentID {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let newPost = try await UserFeedManager.shared.refreshUserFeed(userId: userId, firstDocumentId: firstDocumentId)
            post.insert(contentsOf: newPost, at: 0)
        } else {
            try await getFeed()
        }
    }
    
    func likePost(documentId: String) async throws {
        print(documentId)
    }
}
