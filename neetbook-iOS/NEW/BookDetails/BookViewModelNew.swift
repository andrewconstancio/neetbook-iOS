//
//  BookViewModelNew.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//
import SwiftUI

@MainActor
class BookViewModelNew: ObservableObject {
    
    /// The books comments from the app.
    @Published private(set) var comments: [BookComment] = []
    
    /// Flag if the comments are loading.
    @Published private(set) var isLoadingComments = false
    
    /// A string that is for adding a new comment to the book.
    @Published var newCommentText = ""
    
    @Published var markSelected: String = ""
    @Published var bookshelvesAdded: [String] = []
    @Published var userBookshelves: [Bookshelf] = []
    
    /// A flag the represents if the comment is valid to add. 
    var commentValid: Bool {
        !newCommentText.isEmpty
    }
    
    /// Inserts a new book comment.
    /// - Parameter bookId: The book id.
    func insertComment(bookId: String) async {
        do {
            let newComment = try await BookUserCommentManager.shared.insertBookComment(
                bookId: bookId,
                comment: newCommentText
            )
            
            self.comments.insert(newComment, at: 0)
            newCommentText = ""
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Fetches all of the books comments.
    /// - Parameter id: The id of the book to fetch comments for.
    func fetchComments(id: String) async {
        do {
            isLoadingComments = true
            comments = try await BookUserCommentManager.shared.getAllBookComments(bookId: id)
            isLoadingComments = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Deletes a specific comment by the user.
    /// - Parameters:
    ///   - id: The book id.
    ///   - documentId: The comments firebase document Id.
    func deleteComment(id: String, documentId: String) async {
        do {
            try await BookUserCommentManager.shared.deleteBookComment(bookId: id, documentId: documentId)
            comments =  self.comments.filter { $0.documentId != documentId}
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Reports a specific comment.
    /// - Parameters:
    ///   - id: The book id.
    ///   - documentId: The comments firebase document Id.
    ///   - comment: The comments text that was reported.
    func reportComment(id: String, documentId: String, comment: String) async {
        do {
            try await BookUserCommentManager
                .shared
                .reportComment(bookId: id, commentDocID: documentId, comment: comment)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Fetch the users bookshelves.
    func fetchBookShelves() async {
        do {
            userBookshelves = try await UserManager.shared.fetchUserBookShelves()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveToBookshelves(bookId: String) async {
        do {
            var addedToBookshelvesIds: [String] = []
            var removedFromBookshelvesIds: [String] = []
            
            for bookshelf in userBookshelves {
                if bookshelvesAdded.contains(bookshelf.id) {
                    addedToBookshelvesIds.append(bookshelf.id)
                } else {
                    removedFromBookshelvesIds.append(bookshelf.id)
                }
            }
            
            try await BookUserActionManager.shared.insertIntoBookshelves(bookId: bookId, bookshelvesIds: addedToBookshelvesIds)
            try await BookUserActionManager.shared.removeFromBookshelves(bookId: bookId, bookshelvesIds: removedFromBookshelvesIds)
        } catch {
            print(error.localizedDescription)
        }
    }
}

