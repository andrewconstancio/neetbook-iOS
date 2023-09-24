//
//  LibraryViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import Foundation

final class LibraryViewModel: ObservableObject {
    @Published private(set) var books: [Book] = []
    
    
    
    
    func getUserBooks() async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            self.books = try await BookUserManager.shared.getAllUserAddedBooks(userId: userId)
        } catch {
            throw error
        }
    }
}
