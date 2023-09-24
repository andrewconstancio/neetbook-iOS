//
//  BookActionViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/6/23.
//

import SwiftUI

final class BookActionViewModel: ObservableObject {
    private(set) var userActions: BookUserActionModel? = nil
    
    init() {
        try? self.initUserActions()
    }
    
    private func initUserActions() throws {
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            self.userActions = BookUserActionModel(auth: authUser)
        } catch {
            throw error
        }
    }
    
//    func save(bookId: String, action: ReadingActions, pageCount: Int = 0) {
//        userActions?.bookId = bookId
//        userActions?.pageCount = pageCount
//        
//        switch(action) {
//        case .reading:
//            userActions?.action = "Reading"
//        case .wantToRead:
//            userActions?.action = "Want To Read"
//        case .read:
//            userActions?.action = "Read"
//        }
//        
//        guard let actions = userActions else { return }
//        try? BookUserActionManager.shared.setUserBookAction(userActions: actions)
//    }
}
