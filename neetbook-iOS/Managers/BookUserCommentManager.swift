//
//  BookUserCommentManager.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct BookComment: Identifiable {
    var id = UUID()
    var documentId: String
    let userId: String
    let displayName: String
    let profilePicture: UIImage
    let comment: String?
    let dateCreated: Date
}

final class BookUserCommentManager {
    static var shared = BookUserCommentManager()
    
    private let collection = Firestore.firestore().collection("BookComments")
    private let reportCommentcollection = Firestore.firestore().collection("BookCommentReports")
    
    private var encoder: Firestore.Encoder {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    private var decoder: Firestore.Decoder {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func addUserBookComment(bookId: String, userId: String, comment: String) async throws -> BookComment {
        let docData: [String : Any] = [
            "book_id" : bookId,
            "user_id" : userId,
            "comment" : comment,
            "date_created" : Timestamp(date: Date())
        ]
        
        let doc = try await collection
            .document(bookId)
            .collection("comments")
            .addDocument(data: docData)
        
        let ref = try await doc.getDocument()
        
        UserPostManager.shared.addUserPost(userId: userId, collection: "BookComments", bookId: bookId, documentID: ref.documentID)
        
        var displayName = ""
        let userData = try await UserManager.shared.getUser(userId: userId)
        
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
        
        let bookComment = BookComment(
            documentId: ref.documentID,
            userId: userId,
            displayName: displayName,
            profilePicture: profileImage,
            comment: ref["comment"] as? String,
            dateCreated: (ref["date_created"] as? Timestamp)?.dateValue() ?? Date()
        )
        
        return bookComment
    }
    
    func getAllBookComments(bookId: String) async throws -> [BookComment] {
        let querySnapshot = try await collection
                .document(bookId)
                .collection("comments")
                .order(by: "date_created", descending: true)
                .getDocuments()
        
        return try await withThrowingTaskGroup(of: BookComment.self) { group in
            var comments: [BookComment] = []
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
                        
                        let bookComment = BookComment(
                            documentId: document.documentID,
                            userId: userId,
                            displayName: displayName,
                            profilePicture: profileImage,
                            comment: comment["comment"] as? String,
                            dateCreated: (comment["date_created"] as? Timestamp)?.dateValue() ?? Date()
                        )
                        
                        return bookComment
                    }
                    
                    print("It got here")
                    
                    return BookComment(
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
    
    func deleteBookComment(bookId: String, documentId: String) async throws {
        let document = collection
                .document(bookId)
                .collection("comments")
                .document(documentId)
        
        let data = try await document.getDocument().data()
        
        let user_id = data?["user_id"] as? String ?? ""
        
        try await UserPostManager.shared.deleteUserPost(documentID: document.documentID)
        
        try await document.delete()
    }
    
    func reportComment(bookId: String, commentDocID: String, comment: String) async throws {
        do {
            let docData: [String : Any] = [
                "book_id" : bookId,
                "comment_doc_id" : commentDocID,
                "comment" : comment,
                "date_created" : Timestamp(date: Date())
            ]
            
            try await reportCommentcollection.document(bookId)
                .collection("Reports")
                .addDocument(data: docData)
        } catch {
            throw error
        }
    }
}
