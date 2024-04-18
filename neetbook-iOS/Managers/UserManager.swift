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
import SwiftUI

enum UserError: Error {
    case failedDeleteUserData
}


final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    private let userFollowingListCollection = Firestore.firestore().collection("UserFollowList")
    private let userBookshelvesCollection = Firestore.firestore().collection("userBookshelves")
    private let bookshelvesAddedToCollection = Firestore.firestore().collection("userBookshelvesAddedTo")
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
    
    func createDefaultBookshelves() async throws {
        
        try await saveUserBookshelf(name: "Reading", coverPhoto: nil)
        try await saveUserBookshelf(name: "Want To Read", coverPhoto: nil)
        try await saveUserBookshelf(name: "Finished", coverPhoto: nil)
    }
    
    func getUser(userId: String) async throws -> DBUser? {
        do {
            return try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
            throw APIError.invalidData
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw APIError.invalidData
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw APIError.invalidData
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw APIError.invalidData
        } catch {
            print("error: ", error)
            throw APIError.invalidData
        }
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
                let userData = try await UserManager.shared.getUser(userId: otherUserId)

                
                if let user = userData {
                    let displayName = user.displayname ?? ""
                    let username = user.username ?? ""
                    let hashcode = user.hashcode ?? ""
                    var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                    if let photoUrl = user.photoUrl {
                        profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                    }
                    
                    let followingUser = FollowingUser(
                        userId: otherUserId,
                        displayName: displayName,
                        username: username,
                        hashcode: hashcode,
                        profileImage: profileImage,
                        followingStatus: .following
                    )
                    users.append(followingUser)
                }
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
                let userData = try await UserManager.shared.getUser(userId: otherUserId)
                
                if let user = userData {
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
            }
            return users
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func getUserBookShelves(userId: String) async throws -> [Bookshelf] {
        let docs = try await userBookshelvesCollection
            .document(userId)
            .collection("bookshelves")
            .order(by: "date_created", descending: false)
            .getDocuments()
        
        var bookshelves: [Bookshelf] = []
        for doc in docs.documents {
            let bookshelf = try decoder.decode(Bookshelf.self, from: doc.data())
            bookshelves.append(bookshelf)
        }
        
        return bookshelves
    }
    
    func saveUserBookshelf(name: String, coverPhoto: UIImage?) async throws {
        guard let userId = Firebase.Auth.auth().currentUser?.uid else { return }
        
        var coverPhotoUrl = ""
        
        if let coverPhoto = coverPhoto {
            guard let imageData = coverPhoto.jpegData(compressionQuality: 0.5) else { return }
            
            let storageRef = storage.reference(withPath: "bookshelf_images/\(userId)/\(name)")
            let _ = try await storageRef.putDataAsync(imageData)
            
            coverPhotoUrl = try await storageRef.downloadURL().absoluteString
        }
        
        let bookshelf = Bookshelf(name: name, imageUrl: coverPhotoUrl)
        let data = try encoder.encode(bookshelf)
        
        try await userBookshelvesCollection
            .document(userId)
            .collection("bookshelves")
            .document(bookshelf.id)
            .setData(data, merge: true)
    }
    
    func editUserBookshelf(bookshelf: Bookshelf, name: String, coverPhoto: UIImage?) async throws {
        guard let userId = Firebase.Auth.auth().currentUser?.uid else { return }
        
        var bookshelf = bookshelf
        var coverPhotoUrl = ""
        
        if let coverPhoto = coverPhoto {
            guard let imageData = coverPhoto.jpegData(compressionQuality: 0.5) else { return }
            
            let storageRef = storage.reference(withPath: "bookshelf_images/\(userId)/\(name)")
            let _ = try await storageRef.putDataAsync(imageData)
            
            coverPhotoUrl = try await storageRef.downloadURL().absoluteString
        }
        
        
        bookshelf.setName(name: name)
        bookshelf.setImageUrl(url: coverPhotoUrl)
        
        let data = try encoder.encode(bookshelf)
        
        try await userBookshelvesCollection
            .document(userId)
            .collection("bookshelves")
            .document(bookshelf.id)
            .setData(data, merge: true)
    }
    
    func deleteUserBookshelf(bookshelf: Bookshelf) async throws {
        guard let userId = Firebase.Auth.auth().currentUser?.uid else { return }
        
        let bookshelfDocs = try await userBookshelvesCollection
            .document(userId)
            .collection("bookshelves")
            .whereField("id", isEqualTo: bookshelf.id)
            .getDocuments()
        
        let bookshelfAddedToDocs = try await bookshelvesAddedToCollection
            .whereField("bookshelf_id", isEqualTo: bookshelf.id)
            .getDocuments()
        
        
        for doc in bookshelfDocs.documents {
            try await doc.reference.delete()
        }
        
        for doc in bookshelfAddedToDocs.documents {
            try await doc.reference.delete()
        }
    }
}
 
