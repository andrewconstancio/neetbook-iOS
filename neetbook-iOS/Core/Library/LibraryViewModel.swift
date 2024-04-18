//
//  LibraryViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import Foundation

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published private(set) var booksReading: [Book] = []
    @Published private(set) var booksWantToRead: [Book] = []
    @Published private(set) var booksRead: [Book] = []
    @Published private(set) var shelves: [Bookshelf] = []
    @Published var isLoading: Bool = false
    
    
    func getBookshelves() async throws {
        let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        shelves = try await UserManager.shared.getUserBookShelves(userId: userId)
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
