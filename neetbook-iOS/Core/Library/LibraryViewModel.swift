//
//  LibraryViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import Foundation

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var shelves: [Bookshelf] = []
    @Published var isLoading: Bool = false
    @Published var readingCount: Int = 0
    @Published var wantToReadCount: Int = 0
    @Published var finishedCount: Int = 0
    
    private var bookUserActionManager = BookUserActionManager()
    private var userManager = UserManager()
    
    func getBookshelves() async throws {
        let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        shelves = try await userManager.getUserBookShelves(userId: userId)
        shelves = shelves.filter { $0.name != "Reading" && $0.name != "Want To Read" && $0.name != "Finished" }
    }
    
    func getMarkedBooksCount() async throws {
        let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        readingCount = try await bookUserActionManager.getMarkBooksCounts(userId: userId, markedType: BookListType.reading)
        
        wantToReadCount = try await bookUserActionManager.getMarkBooksCounts(userId: userId, markedType: BookListType.wantToRead)
        
        finishedCount = try await bookUserActionManager.getMarkBooksCounts(userId: userId, markedType: BookListType.finished)
    }
    
    func deleteBookshelf(id: String) async throws {
        do {
            try await userManager.deleteUserBookshelf(bookshelfId: id)
        } catch {
            print(error.localizedDescription)
        }
    }
}
