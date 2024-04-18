//
//  UserStateViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/13/24.
//

import SwiftUI

enum UserState {
    case isLoading
    case loggedOut
    case accountNotMade
    case loggedIn
}

enum UserLoginError: Error {
    case userError
}

@MainActor
class UserStateViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published var userState: UserState = .isLoading
    @Published private(set) var pendingFriendCount: Int = 0
    @Published var isLoading: Bool = true
    
    init()  {
        Task {
//            isLoading = true
            await initFlow()
//            isLoading = false
        }
    }
    
    func initFlow() async {
        let accountMade = try? await checkIfUserAccountMade()
        
        if accountMade == false {
            userState = .accountNotMade
        } else {
            try? await fetchUser()
            try? await getPendingFriendsCount()
            userState = .loggedIn
        }
    }
    
    func checkSignIn() -> Bool {
        AuthenticationManager.shared.checkNotSignIn()
    }
    
    func checkIfUserAccountMade() async throws -> Bool {
        do {
            return try await AuthenticationManager.shared.checkAccountMade()
        } catch {
            throw UserLoginError.userError
        }
    }
    
    func fetchUser() async throws {
        let userId = try? AuthenticationManager.shared.getAuthenticatedUserUserId()
        let user = try? await UserManager.shared.getUser(userId: userId ?? "")
        
        guard var user = user, let photoURL = user.photoUrl else {
            throw APIError.invalidData
        }
        
        // set profile photo
        let image = try await UserManager.shared.getURLImageAsUIImage(path: photoURL)
        user.setUserProfilePic(image: image)
    
        userState = .loggedIn
        self.user = user
    }
    
    func getPendingFriendsCount() async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        pendingFriendCount = try await UserInteractions.shared.getPendingFriendsCount(userId: currentUserId)
    }
}
