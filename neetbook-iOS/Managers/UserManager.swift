//
//  UserManager.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/9/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage


final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    private let storage = Storage.storage()

    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private var encoder: Firestore.Encoder {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    private var decoder: Firestore.Decoder {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func createNewUser(user: DBUser) throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
    }
    
    func checkUserExist(userId: String) async throws -> Bool {
        let userExist: Bool
        let db = Firestore.firestore()
        let userRef = try await db.collection("users").document(userId).getDocument()
        
        
        userExist = userRef.exists ? true : false
        
        return userExist
    }
    
    func checkUserUsernameHashSet(username: String, hash: String) async throws -> Bool {
        let usernameUsabable: Bool

        let query = userCollection
                        .whereField("username", isEqualTo: username)
                        .whereField("hash", isEqualTo: hash)
        
        do {
            let results = try await query.getDocuments()
            usernameUsabable = results.isEmpty ? false : true
            return usernameUsabable
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    
    func saveUserProfileImage(profileImage: UIImage) async throws {
        guard let userId = Firebase.Auth.auth().currentUser?.uid else { return }
        guard let imageData = profileImage.jpegData(compressionQuality: 0.5) else { return }
        
        let storageRef = storage.reference(withPath: "profile_images/\(userId)")
        let _ = try await storageRef.putDataAsync(imageData)
    }
    
    func getProfileProfileImageUrl(userId: String) async throws -> String {
        let storageRef = storage.reference(withPath: "profile_images/\(userId)")
        let downloadUrl = try await storageRef.downloadURL()
        
        
        return downloadUrl.absoluteString
    }
}
 
