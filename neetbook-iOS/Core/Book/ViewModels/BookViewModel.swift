//
//  BookViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/8/23.
//

import SwiftUI

@MainActor
final class BookViewModel: ObservableObject {
    private(set) var currentBookId: String = ""
    private(set) var currentUserId: String = ""
    private(set) var currentUser: DBUser? = nil
    @Published var bookInfoIsLoading: Bool = false
    @Published var userActions: ReadingActions? = nil
    @Published var userNewComment: String = ""
    @Published private(set) var bookComments: [BookComment] = []
    @Published var savedActionToDB: Bool = false
    @Published var savedToFavorites: Bool = false
    @Published var isLoadingComments: Bool = false
    @Published var showCommentSection: Bool = false
    @Published private(set) var userBookshelves: [Bookshelf] = []
    @Published var bookshelvesAdded: [String] = []
    @Published var markSelected: String = ""
    
    var commentValid: Bool {
        return !userNewComment.isEmpty
    }
    
//    init(bookId: String) {
//        Task {
//            bookInfoIsLoading = true
//            currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
//            try await getBookShelves()
//            try await getBookshelvesAddedTo(bookId: bookId)
////            try await getUserBookAction(bookId: bookId)
//            try await checkIfUserAddedBookToFavoritesList(bookId: bookId)
//            try await getBookStats(bookId: bookId)
//            currentUser = try await UserManager.shared.getUser(userId: currentUserId)
//            bookInfoIsLoading = false
//        }
//    }
    
    func initBookDetails(bookId: String) async throws {
        currentBookId = bookId
        bookInfoIsLoading = true
        currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        try await getMarkedBookTypeForUser()
        try await getBookShelves()
        try await getBookshelvesAddedTo(bookId: bookId)
        try await checkIfUserAddedBookToFavoritesList(bookId: bookId)
        currentUser = try await UserManager.shared.getUser(userId: currentUserId)
        bookInfoIsLoading = false
    }
    
    func addUserBookComment(bookId: String) async throws {
        let newComment = try? await BookUserCommentManager.shared.addUserBookComment(bookId: bookId, userId: currentUserId, comment: userNewComment)
        
        if let comment = newComment {
            self.bookComments.insert(comment, at: 0)
        }
        
        userNewComment = ""
    }
    
    func deleteBookComment(bookId: String, documentId: String) async throws {
        try await BookUserCommentManager.shared.deleteBookComment(bookId: bookId, documentId: documentId)
        self.bookComments =  self.bookComments.filter { $0.documentId != documentId}
    }
    
    func getAllBookComments(bookId: String) async throws {
        isLoadingComments = true
        bookComments = try await BookUserCommentManager.shared.getAllBookComments(bookId: bookId)
        isLoadingComments = false
    }
    
    func checkIfUserAddedBookToFavoritesList(bookId: String) async throws {
        savedToFavorites = try await BookUserManager.shared.checkIfBookAddedToFavorites(userId: currentUserId, bookId: bookId)
    }
    
    func reportComment(bookId: String, commentDocID: String, comment: String) async throws {
        try await BookUserCommentManager.shared.reportComment(bookId: bookId,
                                                              commentDocID: commentDocID, comment: comment)
    }
    
    func getBookShelves() async throws {
        userBookshelves = try await UserManager.shared.getUserBookShelves(userId: currentUserId)
    }
    
    func getBookshelvesAddedTo(bookId: String) async throws {
        let bookshelves = try await BookUserActionManager.shared.getBookshelvesOnBookForUser(bookId: bookId, userId: currentUserId)
        
        bookshelvesAdded = []
        for bookshelf in bookshelves {
            bookshelvesAdded.append(bookshelf.bookshelfId)
        }
    }
    
    func saveToBookshelves(bookId: String) async throws {
        var addedToBookshelvesIds: [String] = []
        var removedFromBookshelvesIds: [String] = []
        
        for bookshelf in userBookshelves {
            if bookshelvesAdded.contains(bookshelf.id) {
                addedToBookshelvesIds.append(bookshelf.id)
            } else {
                removedFromBookshelvesIds.append(bookshelf.id)
            }
        }
        
        try await BookUserActionManager.shared.addBookToBookshelves(bookId: bookId, userId: currentUserId, bookshelvesIds: addedToBookshelvesIds)
        try await BookUserActionManager.shared.removeBookToBookshelves(bookId: bookId, userId: currentUserId, bookshelvesIds: removedFromBookshelvesIds)
    }
    
    func getMarkedBookTypeForUser() async throws {
        markSelected = try await BookUserActionManager.shared.getMarkedBookTypeForUser(bookId: currentBookId, userId: currentUserId)
    }
    
    func saveRemoveToMarkedBooks() async throws {
        if markSelected != "" {
            try await BookUserActionManager.shared.saveToMarkedBooks(bookId: currentBookId,
                                                                     userId: currentUserId,
                                                                     markType: markSelected)
        } else {
            try await BookUserActionManager.shared.removeMarkedBook(bookId: currentBookId,
                                                                    userId: currentUserId)
        }
    }
}
