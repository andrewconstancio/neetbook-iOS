//
//  EditProfileViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/31/23.
//

import SwiftUI
import Combine

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var user: DBUser? = nil
    @Published var profileImage: UIImage? = nil
    @Published var displayName: String = ""
    @Published var username: String = ""
    @Published var hashcode: String = ""
    
    private var disposeBag = Set<AnyCancellable>()
    private var finalUsername: String = ""
    
    @Published var formInvalid = false
    @Published var invalidDisplayName = false
    @Published var invalidUsername = false
    var changeAreInvalid = false
    var initalDisplayName = ""
    var initalUsername = ""
    
    init() {
        self.debounceTextChanges()
    }
    
//    func fetchUser() async throws {
//        let userId = try? AuthenticationManager.shared.getAuthenticatedUserUserId()
//        let user = try? await UserManager.shared.getUser(userId: userId ?? "")
//        
//        guard var user = user, let photoURL = user.photoUrl else {
//            throw APIError.invalidData
//        }
//        
//        let image = try await UserManager.shared.getURLImageAsUIImage(path: photoURL)
//        profileImage = image
//        displayName = user.displayname ?? ""
//        username = user.username ?? ""
//        hashcode = user.hashcode ?? ""
//    }
    
    func setEditProperties(user: DBUser) {
        self.displayName = user.displayname ?? ""
        self.username = user.username ?? ""
        self.hashcode = user.hashcode ?? ""
        
        self.initalDisplayName = user.displayname ?? ""
        self.initalUsername = user.username ?? ""
    }
    
    func getProfilePicImage(path: String) async throws {
        self.profileImage = try? await UserManager.shared.getURLImageAsUIImage(path: path)
    }
    
    func validate() {
        formInvalid = false
        if displayName == "" {
            invalidDisplayName = true
        } else {
            invalidDisplayName = false
        }
        
        if username == "" {
            invalidUsername = true
        } else {
            invalidUsername = false
        }
        
        if invalidUsername || invalidDisplayName {
            formInvalid = true
        }
    }
    
    private func debounceTextChanges() {
        $username
            // 1 second debounce
            .debounce(for: 0.3, scheduler: RunLoop.main)

            // Called when text stops updating (stopped typing)
            .sink { [weak self] result in
                if let finalUsername = self?.finalUsername, finalUsername != result, result.count > 3 {
                    if let username = self?.initalUsername {
                        if username != result {
                            Task {
                                try await self?.checkUsername(username: result)
                            }
                        }
                    }
                }
            }
            .store(in: &disposeBag)
    }
    
    func checkUsername(username: String) async throws {
        
        let fourDigitHash = Helpers.shared.generateRandomFourDigitNumberString()
        let usernameExist = try await UserManager.shared.checkUserUsernameHashSet(username: username.lowercased(), hash: fourDigitHash)
        
        if usernameExist {
            try await checkUsername(username: username)
        }
        
        hashcode = fourDigitHash
    }
    
    
    func saveProfileChanges() async throws {
        guard let image = profileImage else {
            return
        }
        
        try await UserManager.shared.saveUserProfileImage(profileImage: image)
        
        if initalDisplayName != displayName {
            try await UserManager.shared.updateUserDisplayName(displayName: displayName)
        }
        
        if initalUsername != username {
            try await UserManager.shared.updateUserName(username: username.lowercased(), hashcode: hashcode)
        }
        
    }
}
