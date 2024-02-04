//
//  ProfileSetUpViewRootViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/17/23.
//

import SwiftUI
import PhotosUI
import Combine
import FirebaseAuth

@MainActor
final class ProfileSetupViewRootViewModel: ObservableObject {
    private(set) var user: DBUser? = nil
    
    private var disposeBag = Set<AnyCancellable>() 
    private var finalUsername: String = ""
    
    @Published var isCreatingNewUser: Bool = false
    @Published var setProgressIndexStep: Int = 1
    @Published var validUsernameAndDisplayName: Bool = false
    @Published var validUsername: Bool = false
    @Published var username: String = ""
    @Published var displayname: String = ""
    @Published var hashcode: String = ""
    @Published var publicAccount: Bool = true
    @Published var validDateOfBirth = false
    @Published var dateOfBirth: Date = Date()
    @Published var profileImage: UIImage?
    @Published var selectedGenres: [String] = []
    
    init() {
        try? initDBUser()
        self.debounceTextChanges()
    }
    
    private func initDBUser() throws {
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = DBUser(auth: authUser)
        } catch {
            throw error
        }
    }
    
    private func debounceTextChanges() {
        $username
            // 1 second debounce
            .debounce(for: 0.3, scheduler: RunLoop.main)

            // Called when text stops updating (stopped typing)
            .sink { [weak self] result in
                if let finalUsername = self?.finalUsername, finalUsername != result, result.count > 3 {
                    Task {
                        try await self?.checkUsername(username: result)
                    }
                } else if result.count <= 3 {
                    self?.clearUsernameValidationProperties()
                }
            }
            .store(in: &disposeBag)
    }
    
    func clearUsernameValidationProperties() {
        hashcode = ""
        validUsername = false
        validUsernameAndDisplayName = false
        
        user?.username = ""
        user?.displayname = ""
        user?.hashcode = ""
    }
    
    func checkUsername(username: String) async throws {
        
        let fourDigitHash = Helpers.shared.generateRandomFourDigitNumberString()
        let usernameExist = try await UserManager.shared.checkUserUsernameHashSet(username: username, hash: fourDigitHash)
        
        if usernameExist {
            try await checkUsername(username: username)
        }
        
        finalUsername = username
        hashcode = fourDigitHash
        validUsername = true
        checkUsernameFormComplete()
    }
    
    func checkUsernameFormComplete() {
        if displayname != "" && validUsername {
            user?.username = username.lowercased()
            user?.displayname = displayname
            user?.hashcode = hashcode
            
            validUsernameAndDisplayName = true
        } else {
            validUsernameAndDisplayName = false
        }
    }
    
    func togglePublicAccount(value: Bool) {
        user?.publicAccount = value
        publicAccount = value
    }
    
    func checkDateOfBirth(dob: Date) {
        let age = Calendar.current.dateComponents([.year, .month, .day], from: dob, to: Date())

        if let years = age.year, years >= 18 {
            user?.dateOfBirth = dob
            validDateOfBirth = true
        } else {
            user?.dateOfBirth = nil
            validDateOfBirth = false
        }
    }
    
    func addSelectedGenresToUser() {
        user?.selectedGenres = selectedGenres
    }
    
    
    func saveUserProfileImage() async throws {
        guard let userId = user?.userId else { return }
        guard let profImage = profileImage else { return }
        
        try await UserManager.shared.saveUserProfileImage(profileImage: profImage)
        let downloadUrl = try await UserManager.shared.getProfileProfileImageUrl(userId: userId)
        
        user?.photoUrl = downloadUrl
    }
    
    func saveUser() async throws {
        guard let newUser = user else { return }
        try UserManager.shared.createNewUser(user: newUser)
    }
}
