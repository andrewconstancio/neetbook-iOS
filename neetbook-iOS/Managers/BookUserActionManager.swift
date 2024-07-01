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
    private let userBookshelvesCollection = Firestore.firestore().collection("userBookshelves")
    private let userMarkedBooks = Firestore.firestore().collection("userMarkedBooks")
    
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
        
        var addToFeed: Bool = false
        var postDocID: String = ""
        
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
                
                let documentSnapshot = userBookshelvesCollection
                        .document(userId)
                        .collection("bookshelves")
                        .document(bookshelvesId)
                
                let docId = ref.documentID
                try await documentSnapshot.setData(["count": FieldValue.increment(Int64(1))], merge: true)
                let data = try await documentSnapshot.getDocument().data()
                let bookshelf = try decoder.decode(Bookshelf.self, from: data as Any)
                
                
                // add to post feed
                let addToPostFeed = bookshelf.isPublic ?? true
                if addToPostFeed {
                    addToFeed = true
                    postDocID = docId
                }
            }
        }
        
        if addToFeed {
            UserPostManager.shared.addUserPost(userId: userId, collection: "userBookshelvesAddedTo", bookId: bookId, documentID: postDocID)
        }
    }
    
    func removeBookToBookshelves(bookId: String, userId: String, bookshelvesIds: [String]) async throws {
        let query = bookshelvesUserscollection
            .whereField("user_id", isEqualTo: userId)
            .whereField("book_id", isEqualTo: bookId)
//            .whereField("bookshelf_id", in: bookshelvesIds)
        
        let querySnapshot = try await query.getDocuments()
        
        for bookshelfId in bookshelvesIds {
            let documents = try await bookshelvesUserscollection
                .whereField("user_id", isEqualTo: userId)
                .whereField("book_id", isEqualTo: bookId)
                .whereField("bookshelf_id", isEqualTo: bookshelfId)
                .getDocuments()
            
            for document in documents.documents {
                let docId = document.reference.documentID
                try await document.reference.delete()
    
                try await UserPostManager.shared.deleteUserPost(documentID: docId)
                
                try await userBookshelvesCollection
                        .document(userId)
                        .collection("bookshelves")
                        .document(bookshelfId)
                        .setData(["count": FieldValue.increment(Int64(-1))], merge: true)
            }
        }
        
//        for document in querySnapshot.documents {
//            let docId = document.reference.documentID
//            try await document.reference.delete()
//            
//            try await UserPostManager.shared.deleteUserPost(documentID: docId)
//        }
    }
    
    func getBooksForBookshelf(bookshelfId: String) async throws -> [BookOnShelf] {
        
        let querySnapshot = try await bookshelvesUserscollection
            .whereField("bookshelf_id", isEqualTo: bookshelfId)
            .order(by: "date_created", descending: true)
            .getDocuments()
        
        var books: [BookOnShelf] = []
        
        try await withThrowingTaskGroup(of: BookOnShelf?.self) { group in
            for document in querySnapshot.documents {
                group.addTask {
                    let data = document.data()
                    let dateAdded = (data["date_created"] as? Timestamp)?.dateValue() ?? Date()
                    
                    if let bookId = data["book_id"] as? String {
                        let book = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
                        if let book = book {
                            let bookInShelf = BookOnShelf(book: book, dateAdded: dateAdded)
                            return bookInShelf
                        }
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
    
    func getMarkedBookTypeForUser(bookId: String, userId: String) async throws -> String {
        let documents = try await userMarkedBooks
            .whereField("user_id", isEqualTo: userId)
            .whereField("book_id", isEqualTo: bookId)
            .getDocuments()
        
        var markType: String = ""
        
        for document in documents.documents {
            let data = document.data()
            markType = data["mark_type"] as? String ?? ""
        }
        
        return markType
    }
    
    func saveToMarkedBooks(bookId: String, userId: String, markType: String) async throws {
        let docData: [String : Any] = [
            "book_id" : bookId,
            "user_id" : userId,
            "mark_type" : markType,
            "date_created" : Timestamp(date: Date())
        ]
        
        let ref = try await userMarkedBooks.addDocument(data: docData)
        
        
        if markType == "finished" {
            UserPostManager.shared.addUserPost(userId: userId,
                                               collection: "userMarkedBooks",
                                               bookId: bookId, documentID: ref.documentID)
        }
    }
    
    func removeMarkedBook(bookId: String, userId: String) async throws {
        let documents = try await userMarkedBooks
            .whereField("user_id", isEqualTo: userId)
            .whereField("book_id", isEqualTo: bookId)
            .getDocuments()
        
        for document in documents.documents {
            try await document.reference.delete()
            try await UserPostManager.shared.deleteUserPost(documentID: document.documentID)
        }
    }
    
    func getMarkedBookTypesForUser(userId: String, markedType: BookListType) async throws -> [MarkedBook] {
        let querySnapshot = try await userMarkedBooks
            .whereField("user_id", isEqualTo: userId)
            .whereField("mark_type", isEqualTo: markedType.rawValue)
            .order(by: "date_created", descending: true)
            .getDocuments()
        
        var books: [MarkedBook] = []
        
        try await withThrowingTaskGroup(of: MarkedBook?.self) { group in
            for document in querySnapshot.documents {
                group.addTask {
                    let data = document.data()
                    let dateAdded = (data["date_created"] as? Timestamp)?.dateValue() ?? Date()
                    
                    if let bookId = data["book_id"] as? String {
                        let book = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
                        if let book = book {
                            let bookInShelf = MarkedBook(id: document.documentID,
                                                         book: book,
                                                         dateAdded: dateAdded)
                            return bookInShelf
                        }
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
    
    func getMarkBooksCounts(userId: String, markedType: BookListType) async throws -> Int {
        let querySnapshotCount = try await userMarkedBooks
            .whereField("user_id", isEqualTo: userId)
            .whereField("mark_type", isEqualTo: markedType.rawValue)
            .getDocuments()
            .count
        
        return querySnapshotCount
    }
}
