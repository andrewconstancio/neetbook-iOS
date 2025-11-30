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
    
    /// An array of post on for the users feed.
    @Published var feedPost: [PostFeedInstance] = []
    
    /// Flag if the feed is loading.
    @Published var isLoadingFeed: Bool = false
    
    /// A document snapshot of the last post document fetched.
    var lastDocument: DocumentSnapshot? = nil
    
    /// Fetches the users feed.
    func fetchFeed(showLoading: Bool = true) async {
        do {
            if showLoading {
                await MainActor.run { self.isLoadingFeed = true }
            }
            
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let (postReturn, lastDocumentReturn) = try await UserFeedManager.shared.getUserHomeFeed(
                userId: userId,
                lastDocument: lastDocument
            )
            
            await MainActor.run {
                self.feedPost.append(contentsOf: postReturn)
                self.lastDocument = lastDocumentReturn
                if showLoading {
                    self.isLoadingFeed = false
                }
            }
        } catch {
            await MainActor.run {
                if showLoading {
                    self.isLoadingFeed = false
                }
            }
            print(error.localizedDescription)
        }
    }

    
    /// Refreshes the users feed.
    func refreshFeed() async  {
        do {
            if let firstDocumentId = feedPost.first?.documentID {
                let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
                let newPost = try await UserFeedManager.shared.refreshUserFeed(userId: userId, firstDocumentId: firstDocumentId)
                feedPost.insert(contentsOf: newPost, at: 0)
            } else {
                await fetchFeed(showLoading: false)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func likePost(documentId: String) async throws {
        print(documentId)
    }
}
