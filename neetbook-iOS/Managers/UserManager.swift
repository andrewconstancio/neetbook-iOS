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
    private let userFollowingListCollection = Firestore.firestore().collection("UserFollowList")
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
    
    
    func getURLImageAsUIImage(path: String) async throws -> UIImage {
        guard let url = URL(string: path) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        
        
        return image
    }
    
    func updateUserDisplayName(displayName: String) async throws {
        guard let userId = Firebase.Auth.auth().currentUser?.uid else { return }
        try await userCollection.document(userId).updateData(["displayname": displayName])
    }
    
    func updateUserName(username: String, hashcode: String) async throws {
        guard let userId = Firebase.Auth.auth().currentUser?.uid else { return }
        try await userCollection.document(userId).updateData(
            ["username": username,"hashcode": hashcode]
        )
    }
    
    func getFollowingCount(userId: String) async throws -> Int {
        let snapshot = try await userFollowingListCollection
                .document(userId)
                .collection("UserFollowing")
                .getDocuments()
        
        
        return snapshot.count
    }
    
    func getFollowerCount(userId: String) async throws -> Int {
        let snapshot = try await userFollowingListCollection
                .document(userId)
                .collection("UserFollowers")
                .getDocuments()
        
        
        return snapshot.count
    }
    
    func getUserFollowing(userId: String) async throws -> [FollowingUser] {
        let query = userFollowingListCollection
                        .document(userId)
                        .collection("UserFollowing")
        
        do {
            let results = try await query.getDocuments()
            var users: [FollowingUser] = []
            for result in results.documents {
                let otherUserId = result["user_id"] as? String ?? ""
                let user = try await UserManager.shared.getUser(userId: otherUserId)
                
                let displayName = user.displayname ?? ""
                let username = user.username ?? ""
                let hashcode = user.hashcode ?? ""
                var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                if let photoUrl = user.photoUrl {
                    profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                }
                
                let newNoti = FollowingUser(
                    userId: otherUserId,
                    displayName: displayName,
                    username: username,
                    hashcode: hashcode,
                    profileImage: profileImage,
                    followingStatus: .following
                )
                users.append(newNoti)
            }
            
            return users
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func getUserFollowers(userId: String) async throws -> [FollowerUser] {
        let query = userFollowingListCollection
                        .document(userId)
                        .collection("UserFollowers")
        
        do {
            let results = try await query.getDocuments()
            var users: [FollowerUser] = []
            for result in results.documents {
                let otherUserId = result["user_id"] as? String ?? ""
                let user = try await UserManager.shared.getUser(userId: otherUserId)
                
                let displayName = user.displayname ?? ""
                let username = user.username ?? ""
                let hashcode = user.hashcode ?? ""
                var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                if let photoUrl = user.photoUrl {
                    profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                }
                
                let followUser = FollowerUser(
                    userId: otherUserId,
                    displayName: displayName,
                    username: username,
                    hashcode: hashcode,
                    profileImage: profileImage
                )
                users.append(followUser)
            }
            return users
        } catch {
            throw URLError(.badServerResponse)
        }
    }
}
 
