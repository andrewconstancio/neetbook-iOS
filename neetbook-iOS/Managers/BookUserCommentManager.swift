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

struct BookComment: Identifiable, Codable {
    var id = UUID()
    let displayName: String
    let photoURL: String
    let comment: String?
    let dateCreated: Date?
}

final class BookUserCommentManager {
    static var shared = BookUserCommentManager()
    
    private let collection = Firestore.firestore().collection("BookComments")
    
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
    
    func addUserBookComment(bookId: String, userId: String, comment: String) throws {
        let docData: [String : Any] = [
            "book_id" : bookId,
            "user_id" : userId,
            "comment" : comment,
            "date_created" : Timestamp(date: Date())
        ]
        
        collection.document(bookId)
            .collection("comments")
            .addDocument(data: docData)
    }
    
    func getAllBookComments(bookId: String) async throws -> [BookComment] {
        let querySnapshot = try await collection
                .document(bookId)
                .collection("comments")
                .order(by: "date_created", descending: true)
                .getDocuments()
        
        var comments: [BookComment] = []
        
        for document in querySnapshot.documents {
            let comment = document.data()
            
            var displayName = ""
            var photoURL = ""
            
            if let userId = comment["user_id"] as? String {
                let userData = try await UserManager.shared.getUser(userId: userId)
                if let name = userData.displayname {
                    displayName = name
                }
                if let profileURL = userData.photoUrl {
                    photoURL = profileURL
                }
            }
         
            let bookComment = BookComment(
                    displayName: displayName,
                    photoURL: photoURL,
                    comment: comment["comment"] as? String,
                    dateCreated: comment["date_created"] as? Date
            )
            
            comments.append(bookComment)
        }
        
        return comments
    }
    
}
