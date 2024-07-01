//
//  BookshelfViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/14/24.
//

import Foundation

struct BookOnShelf: Identifiable {
    let id = UUID().uuidString
    let book: Book
    let dateAdded: Date
}

@MainActor
class BookshelfViewModel: ObservableObject {
    @Published var books: [BookOnShelf] = []
    @Published var isLoadingBooks: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    let bookshelfId: String
    
    init(bookshelfId: String) {
        self.bookshelfId = bookshelfId
        
        Task {
            isLoadingBooks = true
            try await getBooks()
            isLoadingBooks = false
        }
    }
    
    func getBooks() async throws {
        do {
            books = try await BookUserActionManager.shared.getBooksForBookshelf(bookshelfId: bookshelfId)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteBookshelf(bookshelf: Bookshelf) async throws {
        try await UserManager.shared.deleteUserBookshelf(bookshelf: bookshelf)
    }
}
