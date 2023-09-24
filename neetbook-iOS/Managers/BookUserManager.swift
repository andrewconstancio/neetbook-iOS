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

final class BookUserManager {
    
    static var shared = BookUserManager()
    
    private let collection = Firestore.firestore().collection("BookActions")
    
    func getAllUserAddedBooks(userId: String) async throws -> [Book] {
        let querySnapshot = try await collection
                                .whereField("user_id", isEqualTo: userId)
                                .order(by: "date_created", descending: true)
                                .getDocuments()
        
        var userBooks: [Book] = []
        for document in querySnapshot.documents {
            if let bookId = document["book_id"] as? String {
                var book = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
                book.setUserAction(action: document["action"] as? String ?? "")
                userBooks.append(book)
            }
        }
        
        return userBooks
    }
}
