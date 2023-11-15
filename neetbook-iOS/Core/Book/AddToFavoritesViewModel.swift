//
//  AddToFavoritesViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/9/23.
//

import SwiftUI

//struct BookFavorite: Identifiable {
//    let id = UUID()
//    var nr: Int
//    var category: String
//}

@MainActor
class AddToFavoritesViewModel: ObservableObject {
    @Published var books: [FavoriteBook] = []
    
    func getFavoriteBooks(toSaveBook: Book) async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            self.books = try await BookUserManager.shared.getFavoriteBooks(userId: userId)
            
            var newFavBook = FavoriteBook(row: self.books.count + 1, book: toSaveBook, newBook: true)
            var newBookAlreadySaved = false
            var index = 0
            for i in 0..<books.count {
                if books[i].book.bookId == toSaveBook.bookId {
                    newBookAlreadySaved = true
                    books[i].newBook = true
                }
            }
            
            if(!newBookAlreadySaved) {
                self.books.append(newFavBook)
            }
        } catch {
            throw error
        }
    }
    
    func saveFavoriteBooks() async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            var bookIds: [String] = []
            for book in books {
                bookIds.append(book.book.bookId)
            }
            try await BookUserManager.shared.saveFavoriteBooks(userId: userId, bookIds: bookIds)
            
        } catch {
            throw error
        }
    }
}
