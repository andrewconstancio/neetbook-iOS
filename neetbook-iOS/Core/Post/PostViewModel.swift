//
//  PostViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/18/24.
//

import SwiftUI


@MainActor
class PostViewModel: ObservableObject {
    @Published var postComments: [PostComment] = []
    @Published var userNewComment: String = ""
    
    func getComments(documentId: String) async throws {
        postComments = try await UserPostManager.shared.getPostComments(documentId: documentId)
    }
    
    func addComment(posterUserId: String, documentId: String) async throws {
        if userNewComment != "" {
            let comment = try await UserPostManager.shared.addCommentToPost(posterUserId: posterUserId, documentId: documentId, comment: userNewComment)
            
            postComments.insert(comment, at: 0)
            userNewComment = ""
        }
    }
    
    func deleteComment(documentId: String) async throws {
        try await UserPostManager.shared.deletePostComment(documentId: documentId)
        DispatchQueue.main.async {
            self.postComments =  self.postComments.filter { $0.documentId != documentId}
        }
    }
    
    func reportComment(commentDocID: String, comment: String) async throws {
        try await UserPostManager.shared.reportComment(commentDocID: commentDocID, comment: comment)
    }
}
