//
//  BookViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/8/23.
//

import SwiftUI

@MainActor
final class BookViewModel: ObservableObject {
    @Published var userActions: ReadingActions? = nil
    @Published var userNewComment: String = ""
    @Published private(set) var bookComments: [BookComment] = []
    
    
    func getUserBookAction(bookId: String) async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            let action = try await BookUserActionManager.shared.getUserBookAction(bookId: bookId, userId: userId)
        
            DispatchQueue.main.async {
                switch action {
                case "Reading":
                    self.userActions = .reading
                case "Want To Read":
                    self.userActions = .wantToRead
                case "Read":
                    self.userActions = .read
                default:
                    self.userActions = nil
                }
            }
        } catch {
            throw error
        }
    }
    
    func saveUserBookAction(bookId: String, action: ReadingActions, pageCount: Int = 0) async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            var actionUser = ""
            switch(action) {
            case .reading:
                actionUser = "Reading"
            case .wantToRead:
                actionUser = "Want To Read"
            case .read:
                actionUser = "Read"
            case .removeAction:
                actionUser = "Remove"
            }
            
            if actionUser == "Remove" {
                DispatchQueue.main.async {
                    self.userActions = nil
                }
                try? await BookUserActionManager.shared.removeUserBookAction(bookId: bookId, userId: userId)
            } else {
                DispatchQueue.main.async {
                    self.userActions = action
                }
                try? BookUserActionManager.shared.setUserBookAction(bookId: bookId, userId: userId, action: actionUser)
            }
            
        } catch {
            throw error
        }
    }
    
    func addUserBookComment(bookId: String) async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
            try? BookUserCommentManager.shared.addUserBookComment(bookId: bookId, userId: userId, comment: userNewComment)
        } catch {
            throw error
        }
    }
    
    func getAllBookComments(bookId: String) async throws {
        self.bookComments = try await BookUserCommentManager.shared.getAllBookComments(bookId: bookId)
    }
}
