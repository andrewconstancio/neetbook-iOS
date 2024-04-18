//
//  BookViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/8/23.
//

import SwiftUI

@MainActor
final class BookViewModel: ObservableObject {
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
    @Published private(set) var bookStats: BookActionStats? = nil
    @Published var bookshelvesAdded: [String] = []
    
    init(bookId: String) {
        Task {
            bookInfoIsLoading = true
            currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try await getBookShelves()
            try await getBookshelvesAddedTo(bookId: bookId)
//            try await getUserBookAction(bookId: bookId)
            try await checkIfUserAddedBookToFavoritesList(bookId: bookId)
            try await getBookStats(bookId: bookId)
            currentUser = try await UserManager.shared.getUser(userId: currentUserId)
            bookInfoIsLoading = false
        }
    }
        
//    func getUserBookAction(bookId: String) async throws {
//        do {
//            let action = try await BookUserActionManager.shared.getUserBookAction(bookId: bookId, userId: currentUserId)
//            
//            DispatchQueue.main.async {
//                switch action {
//                case "Reading":
//                    self.savedActionToDB = true
//                    self.userActions = .reading
//                case "Want To Read":
//                    self.savedActionToDB = true
//                    self.userActions = .wantToRead
//                case "Read":
//                    self.savedActionToDB = true
//                    self.userActions = .read
//                default:
//                    self.userActions = nil
//                }
//            }
//        } catch {
//            throw error
//        }
//    }
    
//    func saveUserBookAction(bookId: String, action: ReadingActions, pageCount: Int = 0) async throws {
//        do {
//            var actionUser = ""
//            switch(action) {
//            case .reading:
//                actionUser = "Reading"
//            case .wantToRead:
//                actionUser = "Want To Read"
//            case .read:
//                actionUser = "Read"
//            case .removeAction:
//                actionUser = "Remove"
//            }
//            
//            if actionUser == "Remove" {
//                DispatchQueue.main.async {
//                    self.userActions = nil
//                }
//                try await BookUserActionManager.shared.removeUserBookAction(bookId: bookId, userId: currentUserId)
//                self.savedActionToDB = false
//            } else {
//                DispatchQueue.main.async {
//                    self.userActions = action
//                }
//                try await BookUserActionManager.shared.removeAndSetBookAction(bookId: bookId, userId: currentUserId, action: actionUser)
//                self.savedActionToDB = true
//            }
//            
//        } catch {
//            throw error
//        }
//    }
    
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
    
    func getBookStats(bookId: String) async throws {
        bookStats = try await BookUserActionManager.shared.getBookActionStats(bookId: bookId)
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
}
