//
//  UserPostManager.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/17/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PostComment: Identifiable {
    var id = UUID()
    var documentId: String
    let userId: String
//    let postUserId: String
    let displayName: String
    let profilePicture: UIImage
    let comment: String?
    let dateCreated: Date
}


final class UserPostManager {
    static var shared = UserPostManager()
    
    private let postCollection = Firestore.firestore().collection("UserPost")
    private let postCollectionComments = Firestore.firestore().collection("UserPostComments")
    private let postCollectionReports = Firestore.firestore().collection("UserPostCommentsReports")
    private let likedPostCollection = Firestore.firestore().collection("UserLikedPost")
    
    
    func addUserPost(userId: String, collection: String, bookId: String, documentID: String) {
        let docData: [String : Any] = [
            "user_id" : userId,
            "collection" : collection,
            "document_id" : documentID,
            "book_id" : bookId,
            "date_created" : Timestamp(date: Date())
        ]
        
        postCollection.document().setData(docData, merge: true)
    }
    
    func deleteUserPost(documentID: String) async throws {
        let querySnapshot = try await postCollection
            .whereField("document_id", isEqualTo: documentID)
            .getDocuments()
        
        if let document = querySnapshot.documents.first {
            try await document.reference.delete()
        }
    }
    
    func getPost(documentID: String) async throws -> PostFeedInstance? {
        let document = try await postCollection.document(documentID).getDocument()
        return try await UserFeedManager.shared.buildPostInstance(result: document) ?? nil
    }
    
    func getPostLikesCount(documentId: String) async throws -> Int {
        let querySnapshot = try await likedPostCollection
            .whereField("post_document_id", isEqualTo: documentId)
            .getDocuments()
        
        return querySnapshot.documents.count
    }
    
    func checkPostLiked(documentId: String) async throws -> Bool {
        let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            
        let querySnapshot = try await likedPostCollection
            .whereField("post_document_id", isEqualTo: documentId)
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        
        return querySnapshot.isEmpty ? false : true
    }
    
    func likePost(documentId: String) async throws {
        let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        
        
        let docData: [String : Any] = [
            "user_id" : userId,
            "post_document_id" : documentId,
            "action" : "liked",
            "date_created" : Timestamp(date: Date())
        ]
        
        try await likedPostCollection.document().setData(docData)
    }
    
    func unlikePost(documentId: String) async throws {
        let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            
        let querySnapshot = try await likedPostCollection
            .whereField("post_document_id", isEqualTo: documentId)
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        for document in querySnapshot.documents {
            try await document.reference.delete()
        }
    }
    
    
    func getPostComments(documentId: String) async throws -> [PostComment] {
        let querySnapshot = try await postCollectionComments
            .whereField("post_document_id", isEqualTo: documentId)
            .getDocuments()
        
        return try await withThrowingTaskGroup(of: PostComment.self) { group in
            var comments: [PostComment] = []
            for document in querySnapshot.documents {
                group.addTask {
                    let comment = document.data()
                    var displayName = ""
                    let userId = comment["user_id"] as? String ?? ""
                    let userData = try await UserManager.shared.getUser(userId: userId)
                    if let user = userData {
                        if let name = user.displayname {
                            displayName = name
                        }
                        
                        var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                        if let photoUrl = user.photoUrl {
                            profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                        }
                        
                        let comment = PostComment(
                            documentId: document.documentID,
                            userId: userId,
                            displayName: displayName,
                            profilePicture: profileImage,
                            comment: comment["comment"] as? String,
                            dateCreated: (comment["date_created"] as? Timestamp)?.dateValue() ?? Date()
                        )
                        
                        return comment
                    }
                    
                    return PostComment(
                        documentId: document.documentID,
                        userId: "1234",
                        displayName: "Delete User",
                        profilePicture: UIImage(imageLiteralResourceName: "circle-user-regular"),
                        comment: comment["comment"] as? String,
                        dateCreated: (comment["date_created"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
            }
            
            for try await comment in group {
                comments.append(comment)
            }
            
            comments.sort { $0.dateCreated > $1.dateCreated }
            
            return comments
        }
    }
    
    func addCommentToPost(posterUserId: String, documentId: String, comment: String) async throws -> PostComment {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        
        let docData: [String : Any] = [
            "user_id" : currentUserId,
            "post_document_id" : documentId,
            "comment" : comment,
            "date_created" : Timestamp(date: Date())
        ]
        
        let doc = try await postCollectionComments.addDocument(data: docData)
        
        let ref = try await doc.getDocument()
        
        var displayName = ""
        let userData = try await UserManager.shared.getUser(userId: currentUserId)
        
        guard let user = userData else {
            throw APIError.invalidData
        }
        
        if let name = user.displayname {
            displayName = name
        }
        
        var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
        if let photoUrl = user.photoUrl {
            profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
        }
        
        let commentData = ref["comment"] as? String ?? ""
        
        let comment = PostComment(
            documentId: ref.documentID,
            userId: currentUserId,
            displayName: displayName,
            profilePicture: profileImage,
            comment: commentData,
            dateCreated: (ref["date_created"] as? Timestamp)?.dateValue() ?? Date()
        )
        
        try await UserInteractions.shared.addToNotificationComment(postDocumentId: documentId,
                                                                    commentDocumentId:        doc.documentID,
                                                                    comment: commentData,
                                                                    currentUserId: currentUserId,
                                                                    userId: posterUserId)
        
        return comment
    }
    
    func deletePostComment(documentId: String) async throws {
        let data = try await postCollectionComments
            .document(documentId)
            .getDocument()
            .data()
        
        try await UserInteractions.shared.removeNotificationPostComment(commentDocumentId: documentId)
    }
    
    func reportComment(commentDocID: String, comment: String) async throws {
        let docData: [String : Any] = [
            "comment_doc_id" : commentDocID,
            "comment" : comment,
            "date_created" : Timestamp(date: Date())
        ]
        
        try await postCollectionReports
            .addDocument(data: docData)
    }
}
