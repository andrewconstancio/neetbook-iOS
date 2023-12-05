//
//  BookUserActionManager.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/6/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct BookUserActionModel: Codable {
    var uid: String
    var bookId: String
    var action: String
    var pageCount: Int?
    
    init(auth: AuthDataResultModel) {
        self.uid = auth.uid
        self.bookId = "bookId"
        self.action = ""
        self.pageCount = 0
    }
}

struct BookActionStats {
    let readingCount: Int
    let wantToReadCount: Int
    let readCount: Int
}

final class BookUserActionManager {
    
    
    static var shared = BookUserActionManager()
    
    private let collection = Firestore.firestore().collection("BookActions")
    
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
    
    
    func setUserBookAction(bookId: String, userId: String, action: String) throws {
        let docData: [String : Any] = [
            "book_id" : bookId,
            "user_id" : userId,
            "action" : action,
            "date_created" : Timestamp(date: Date())
        ]
        
        collection.document(bookId).setData(docData, merge: true)
    }
    
    func removeUserBookAction(bookId: String, userId: String) async throws {
        let querySnapshot = try await collection
            .whereField("book_id", isEqualTo: bookId)
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        if let document = querySnapshot.documents.first {
            try await document.reference.delete()
        }
    }
    
    func getUserBookAction(bookId: String, userId: String) async throws -> String {
        do {
            let querySnapshot = try await collection
                .whereField("book_id", isEqualTo: bookId)
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()
            
            if let document = querySnapshot.documents.first {
                let data = document.data()
                if let action = data["action"] as? String {
                    return action
                }
            }
            
            return ""
        } catch {
            throw error
        }
    }
    
    func getBookActionStats(bookId: String) async throws -> BookActionStats {
        let readingQuerySnapshot = collection
            .whereField("book_id", isEqualTo: bookId)
            .whereField("action", isEqualTo: "Reading")
        
        let wantToReadQuerySnapshot = collection
            .whereField("book_id", isEqualTo: bookId)
            .whereField("action", isEqualTo: "Want To Read")
        
        let readQuerySnapshot = collection
            .whereField("book_id", isEqualTo: bookId)
            .whereField("action", isEqualTo: "Read")
        
        
        let dataReadingCount = try await readingQuerySnapshot.getDocuments().count
        let dataWantToReadCount = try await wantToReadQuerySnapshot.getDocuments().count
        let dataReadCount = try await readQuerySnapshot.getDocuments().count
        
        return BookActionStats(readingCount: dataReadingCount, wantToReadCount: dataWantToReadCount, readCount: dataReadCount)
    }
}
