//
//  PostViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/18/24.
//

import SwiftUI

@MainActor
class PostViewModel: ObservableObject {
    
    /// An array of user comments for the post.
    @Published var postComments: [PostComment] = []
    
    /// A string for a new comment.
    @Published var newComment: String = ""
    
    /// A flag to check if the comment is valid.
    var commentValid: Bool {
        return !newComment.isEmpty
    }
    
    
    /// Fetches the comments for the post.
    /// - Parameter documentId: The post document id from firebase.
    func fetchPostComments(documentID: String) async {
        do {
            postComments = try await UserPostManager.shared.getPostComments(documentId: documentID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Inserts a new comment on the post.
    /// - Parameters:
    ///   - postUserID: The post users id.
    ///   - documentId: The post document id from firebase.
    func insertComment(postUserID: String, documentId: String) async {
        do {
            let comment = try await UserPostManager.shared.addCommentToPost(posterUserId: postUserID, documentId: documentId, comment: newComment)
            
            postComments.insert(comment, at: 0)
            newComment = ""
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    /// Deletes a comment from the post.
    /// - Parameter documentId: The post document id from firebase.
    func deleteComment(documentId: String) async {
        do {
            try await UserPostManager.shared.deletePostComment(documentId: documentId)
            DispatchQueue.main.async {
                self.postComments =  self.postComments.filter { $0.documentId != documentId}
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    /// Reports a comment that is on the post.
    /// - Parameters:
    ///   - commentDocumentID: The comments document ID that is reported from firebase.
    ///   - comment: The comments text that is reported.
    func reportComment(commentDocumentID: String, comment: String) async {
        do {
            try await UserPostManager.shared.reportComment(commentDocID: commentDocumentID, comment: comment)
        } catch {
            print(error.localizedDescription)
        }
    }
}
