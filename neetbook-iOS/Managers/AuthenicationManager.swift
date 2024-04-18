//
//  AuthenicationManager.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/8/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

enum AuthErrors: Error {
    case couldNotDeleteAccountSignOut
}

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
     
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() {}
    private let userCollection = Firestore.firestore().collection("users")
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func getAuthenticatedUserUserId() throws -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw URLError(.badServerResponse)
        }
        
        return userId
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    func checkNotSignIn() -> Bool {
        if Auth.auth().currentUser != nil {
          return false
        } else {
          return true
        }
    }
    
    func checkAccountMade() async throws -> Bool {
        guard let userAuth = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        
        let user = try? await UserManager.shared.getUser(userId: userAuth.uid)
        return user != nil
    }
    
    func signOut() throws {
        guard let _ = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try Auth.auth().signOut()
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        do {
            try await user.delete()
            try await deleteUserProfile(userId: user.uid)
        } catch {
            throw AuthErrors.couldNotDeleteAccountSignOut
        }
    }
    
    func deleteUserProfile(userId: String) async throws {
        do {
            let document = userCollection.document(userId)
            try await document.delete()
        } catch {
            throw AuthErrors.couldNotDeleteAccountSignOut
        }
    }
}


// MARK: SIGN IN EMAIL
extension AuthenticationManager {
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    func signInDevTestingUser() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: "andrewconstancio7@gmail.com", password: "8Time!Cool8")
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPasswordEmail(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
}

extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accesstoken)
        return try await signIn(credenital: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credenital: credential)
    }
    
    func signIn(credenital: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult =  try await Auth.auth().signIn(with: credenital)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
