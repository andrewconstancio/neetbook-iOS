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
    private let bookshelvesUserscollection = Firestore.firestore().collection("userBookshelvesAddedTo")
    
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
    
//    func removeAndSetBookAction(bookId: String, userId: String, action: String) async throws {
//        try await removeUserBookAction(bookId: bookId, userId: userId)
//        try setUserBookAction(bookId: bookId, userId: userId, action: action)
//    }
//    
//    
//    func setUserBookAction(bookId: String, userId: String, action: String) throws {
//        let docData: [String : Any] = [
//            "book_id" : bookId,
//            "user_id" : userId,
//            "action" : action,
//            "date_created" : Timestamp(date: Date())
//        ]
//        
//        let ref = collection
//            .document()
//        
//        ref.setData(docData, merge: true)
//        
//        let docId = ref.documentID
//        
//        UserPostManager.shared.addUserPost(userId: userId, collection: "BookActions", bookId: bookId, documentID: docId)
//    }
//    
//    func removeUserBookAction(bookId: String, userId: String) async throws {
//        let querySnapshot = try await collection
//            .whereField("book_id", isEqualTo: bookId)
//            .whereField("user_id", isEqualTo: userId)
//            .getDocuments()
//        
//        if let document = querySnapshot.documents.first {
//            
//            try await UserPostManager.shared.deleteUserPost(userId: userId, collection: "BookActions", documentID: document.documentID)
//            try await document.reference.delete()
//        }
//        
//    }
    
//    func getUserBookAction(bookId: String, userId: String) async throws -> String {
//        do {
//            let querySnapshot = try await collection
//                .whereField("book_id", isEqualTo: bookId)
//                .whereField("user_id", isEqualTo: userId)
//                .getDocuments()
//            
//            if let document = querySnapshot.documents.first {
//                let data = document.data()
//                if let action = data["action"] as? String {
//                    return action
//                }
//            }
//            
//            return ""
//        } catch {
//            throw error
//        }
//    }
    
    func getBookActionStats(bookId: String) async throws -> BookActionStats {
        let readingQuerySnapshot = collection
            .whereField("book_id", isEqualTo: bookId)
        
        let wantToReadQuerySnapshot = collection
            .whereField("book_id", isEqualTo: bookId)
        
        let readQuerySnapshot = collection
            .whereField("book_id", isEqualTo: bookId)
        
        
        let dataReadingCount = try await readingQuerySnapshot.getDocuments().count
        let dataWantToReadCount = try await wantToReadQuerySnapshot.getDocuments().count
        let dataReadCount = try await readQuerySnapshot.getDocuments().count
        
        return BookActionStats(readingCount: dataReadingCount, wantToReadCount: dataWantToReadCount, readCount: dataReadCount)
    }
    
    func getBookshelvesOnBookForUser(bookId: String, userId: String) async throws -> [BookshelfAddedTo] {
        var bookshelves: [BookshelfAddedTo] = []
        
        let query = bookshelvesUserscollection
            .whereField("user_id", isEqualTo: userId)
            .whereField("book_id", isEqualTo: bookId)
        
        let querySnapshot = try await query.getDocuments()
        
        for doc in querySnapshot.documents {
            let bookshelf = try decoder.decode(BookshelfAddedTo.self, from: doc.data())
            bookshelves.append(bookshelf)
        }
        
        return bookshelves
    }
    
    func addBookToBookshelves(bookId: String, userId: String, bookshelvesIds: [String]) async throws {
        for bookshelvesId in bookshelvesIds {
            
            let querySnapshot = try await bookshelvesUserscollection
                .whereField("user_id", isEqualTo: userId)
                .whereField("book_id", isEqualTo: bookId)
                .whereField("bookshelf_id", isEqualTo: bookshelvesId)
                .getDocuments()
            
            if querySnapshot.isEmpty {
                let docData: [String : Any] = [
                    "book_id" : bookId,
                    "user_id" : userId,
                    "bookshelf_id" : bookshelvesId,
                    "date_created" : Timestamp(date: Date())
                ]
                
                let ref = bookshelvesUserscollection.document()
                try await ref.setData(docData, merge: true)
                let docId = ref.documentID
                
                // add to post feed
                UserPostManager.shared.addUserPost(userId: userId, collection: "userBookshelvesAddedTo", bookId: bookId, documentID: docId)
            }
        }
    }
    
    func removeBookToBookshelves(bookId: String, userId: String, bookshelvesIds: [String]) async throws {
        let query = bookshelvesUserscollection
            .whereField("user_id", isEqualTo: userId)
            .whereField("book_id", isEqualTo: bookId)
            .whereField("bookshelf_id", in: bookshelvesIds)
        
        let querySnapshot = try await query.getDocuments()
        
//        print(querySnapshot.count)
        
        for document in querySnapshot.documents {
            let docId = document.reference.documentID
            try await document.reference.delete()
            
            try await UserPostManager.shared.deleteUserPost(documentID: docId)
        }
//        for bookshelf in bookshelves {
//            let query = bookshelvesUserscollection
//                .whereField("user_id", isEqualTo: userId)
//                .whereField("book_id", isEqualTo: bookId)
//                .whereField("bookshelf", isEqualTo: bookshelf)
//            
//            let querySnapshot = try await query.getDocuments()
//            
//            for document in querySnapshot.documents {
//                try await document.reference.delete()
//            }
//        }
    }
    
    func getBooksForBookshelf(bookshelfId: String) async throws -> [Book] {
        
        let querySnapshot = try await bookshelvesUserscollection
            .whereField("bookshelf_id", isEqualTo: bookshelfId)
            .order(by: "date_created", descending: true)
            .getDocuments()
        
        var books: [Book] = []
        
        try await withThrowingTaskGroup(of: Book?.self) { group in
            for document in querySnapshot.documents {
                group.addTask {
                    let data = document.data()
                    
                    if let bookId = data["book_id"] as? String {
                        let book = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
                        return book
                    }
                    
                    return nil
                }
                
                for try await book in group {
                    if let book = book {
                        books.append(book)
                    }
                }
            }
        }
        return books
    }
}
