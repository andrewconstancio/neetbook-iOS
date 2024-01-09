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
    @Published var isLoading: Bool = false
    
    func getUserBooks() async throws {
        do {
//            isLoading = true
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            booksReading = try await BookUserManager.shared.getReadingUserAddedBooks(userId: userId)
            booksWantToRead = try await BookUserManager.shared.getWantToReadUserAddedBooks(userId: userId)
            booksRead = try await BookUserManager.shared.getReadUserAddedBooks(userId: userId)
//            isLoading = false
        } catch {
            throw error
        }
    }
}
