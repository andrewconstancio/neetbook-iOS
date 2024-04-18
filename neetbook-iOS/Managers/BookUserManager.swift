//
//  BookUserManager.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FavoriteBook: Identifiable {
    let id = UUID()
    var row: Int
    var book: Book
    var newBook: Bool = false
    
    mutating func setRowNumber(num: Int){
        self.row = num
    }
}

final class BookUserManager {
    
    static var shared = BookUserManager()
    
    private let collection = Firestore.firestore().collection("BookActions")
    private let userCollection = Firestore.firestore().collection("users")
    
    func getFavoriteBooks(userId: String) async throws -> [FavoriteBook] {
        let querySnapshot = try await userCollection.document(userId).getDocument()
        
        var userBooks: [FavoriteBook] = []
        let data = querySnapshot.data()
        var index = 1
        if let favBooks = data?["favorite_books"] as? [String] {
            for bookId in favBooks {
                let book = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
                if var foundBook = book {
                    let favoriteBook = FavoriteBook(row: index, book: foundBook)
                    userBooks.append(favoriteBook)
                    index += 1
                }
            }
        }
        
        return userBooks
    }
    
    func saveFavoriteBooks(userId: String, bookIds: [String]) async throws {
        try await userCollection.document(userId).updateData(["favorite_books": bookIds])
    }
    
    func checkIfBookAddedToFavorites(userId: String, bookId: String) async throws -> Bool {
        let querySnapshot = try await userCollection.document(userId).getDocument()
        let data = querySnapshot.data()
        var added = false
        if let favBookIds = data?["favorite_books"] as? [String] {
            for favBookId in favBookIds {
                if bookId == favBookId {
                    added = true
                }
            }
        }
        
        return added
    }
}
