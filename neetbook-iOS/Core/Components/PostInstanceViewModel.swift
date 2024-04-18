//
//  PostInstanceViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/15/24.
//

import Foundation


@MainActor
class PostInstanceViewModel: ObservableObject {
    @Published var likes: Int = 0
    @Published var isLikedByUser: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    func fetchLikes(for postId: String) async {
        do {
            isLikedByUser = try await UserPostManager.shared.checkPostLiked(documentId: postId)
            likes = try await UserPostManager.shared.getPostLikesCount(documentId: postId)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func updateLikes(for post: PostFeedInstance) async {
        do {
            if isLikedByUser {
                isLikedByUser = false
                likes -= 1
                try await UserPostManager.shared.unlikePost(documentId: post.documentID)
                try await UserInteractions.shared.addToNotificationLike(for: post)
            } else {
                isLikedByUser = true
                likes += 1
                try await UserPostManager.shared.likePost(documentId: post.documentID)
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
}
