//
//  LibraryViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import Foundation

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published private(set) var shelves: [Bookshelf] = []
    @Published var isLoading: Bool = false
    @Published var readingCount: Int = 0
    @Published var wantToReadCount: Int = 0
    @Published var finishedCount: Int = 0
    
    private var bookUserActionManager = BookUserActionManager()
    
    
    func getBookshelves() async throws {
        let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        shelves = try await UserManager.shared.getUserBookShelves(userId: userId)
    }
    
    func getMarkedBooksCount() async throws {
        let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        readingCount = try await bookUserActionManager.getMarkBooksCounts(userId: userId, markedType: BookListType.reading)
        
        wantToReadCount = try await bookUserActionManager.getMarkBooksCounts(userId: userId, markedType: BookListType.wantToRead)
        
        finishedCount = try await bookUserActionManager.getMarkBooksCounts(userId: userId, markedType: BookListType.finished)
    }
    
    
//    func getUserBooks() async throws {
//        do {
//            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
//            booksReading = try await BookUserManager.shared.getReadingUserAddedBooks(userId: userId)
//            booksWantToRead = try await BookUserManager.shared.getWantToReadUserAddedBooks(userId: userId)
//            booksRead = try await BookUserManager.shared.getReadUserAddedBooks(userId: userId)
//        } catch {
//            throw error
//        }
//    }
}
