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
    enum CodingKeys: CodingKey {
          case id, documentId, userId, displayName, profilePicture, comment, dateCreated
    }
    
    var id = UUID()
    var documentId: String
    let userId: String
    let displayName: String
    let profilePicture: UIImage
    let comment: String?
    let dateCreated: Date?
    
//    let savePath = FileManager.documentsDirectory.appendingPathComponent("ImageContext")
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = try container.decode(UUID.self, forKey: .id)
//        documentId = try container.decode(String.self, forKey: .documentId)
//        displayName = try container.decode(String.self, forKey: .displayName)
//        comment = try container.decode(String.self, forKey: .comment)
//        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
//
//         let imageData = try container.decode(Data.self, forKey: .profilePicture)
//         let decodedImage = UIImage(data: imageData) ?? UIImage()
//         self.profilePicture = decodedImage
//     }
//
//     func encode(to encoder: Encoder) throws {
//         var container = encoder.container(keyedBy: CodingKeys.self)
//         try container.encode(id, forKey: .id)
//         try container.encode(documentId, forKey: .documentId)
//         try container.encode(displayName, forKey: .displayName)
//         try container.encode(comment, forKey: .comment)
//         try container.encode(dateCreated, forKey: .dateCreated)
//
//         if let jpegData = profilePicture.jpegData(compressionQuality: 0.8) {
//             try? jpegData.write(to: savePath, options: [.atomic, .completeFileProtection]) // Do I need this line? Everything works without it
//             try container.encode(jpegData, forKey: .profilePicture)
//         }
//     }
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
    
    func addUserBookComment(bookId: String, userId: String, comment: String) async throws {
        let docData: [String : Any] = [
            "book_id" : bookId,
            "user_id" : userId,
            "comment" : comment,
            "date_created" : Timestamp(date: Date())
        ]
        
        let doc = try await collection.document(bookId)
            .collection("comments")
            .addDocument(data: docData)
        
        let ref = try await doc.getDocument()
        let data = ref.data()
        print(data)
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
                
                var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                if let photoUrl = userData.photoUrl {
                    profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                }
                
                let bookComment = BookComment(
                    documentId: document.documentID,
                    userId: userId,
                    displayName: displayName,
                    profilePicture: profileImage,
                    comment: comment["comment"] as? String,
                    dateCreated: comment["date_created"] as? Date
                )
                
                comments.append(bookComment)
            }
        }
        
        return comments
    }
    
    func deleteBookComment(bookId: String, documentId: String) async throws {
        let document = collection
                .document(bookId)
                .collection("comments")
                .document(documentId)
        
        try await document.delete()
    }
}
