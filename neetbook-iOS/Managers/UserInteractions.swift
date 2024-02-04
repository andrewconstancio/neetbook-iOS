//
//  UserSearch.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/23.
//


import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


struct UserSearchResult: Identifiable, Hashable {
    let id: String
    let displayName: String
    let username: String
    let hashcode: String
    let profileURL: String
    let profilePicture: UIImage
}

final class UserInteractions {
    
    static let shared = UserInteractions()
    
    private let userCollection = Firestore.firestore().collection("users")
    private let userFollowRequestCollection = Firestore.firestore().collection("UserFollowRequest")
    private let userFollowingListCollection = Firestore.firestore().collection("UserFollowList")
    
    func searchForUser(searchText: String, currentUserId: String) async throws -> [UserSearchResult] {
        print("searchText: \(searchText)")
        let query = userCollection
            .whereField("username", isEqualTo: searchText)
                .whereField("user_id", isNotEqualTo: currentUserId)
        
        let data = try await query.getDocuments()
        var searchUsers: [UserSearchResult] = []
        for document in data.documents {
            let user_id = document["user_id"] as? String ?? ""
            let name = document["displayname"] as? String ?? ""
            let username = document["username"] as? String ?? ""
            let hashcode = document["hashcode"] as? String ?? ""
            let photoURL = document["photo_url"] as? String ?? ""
             
            if let url = URL(string: photoURL) {
                let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
                let image = Helpers.shared.convertDataToUIImage(data: data, response: response)
                
                if let profileImage = image {
                    let user = UserSearchResult(
                        id: user_id,
                        displayName: name,
                        username: username,
                        hashcode: hashcode,
                        profileURL: photoURL,
                        profilePicture: profileImage
                    )
                    searchUsers.append(user)
                } else {
                    let user = UserSearchResult(
                        id: user_id,
                        displayName: name,
                        username: username,
                        hashcode: hashcode,
                        profileURL: photoURL,
                        profilePicture: UIImage(imageLiteralResourceName: "circle-user-regular")
                    )
                    searchUsers.append(user)
                }
            }

        }
        
        return searchUsers
    }
    
    func requestToFollow(currentUserId: String, userId: String) async throws {
        let docData: [String : Any] = [
            "current_user_id" : currentUserId,
            "request_to_follow_user_id" : userId,
            "accepted" : false,
            "date_created" : Timestamp(date: Date())
        ]
        
        try await userFollowRequestCollection.document().setData(docData, merge: true)
    }
    
    func checkUserFollowing(currentUserId: String, userId: String) async throws -> Bool {
        do {
            let query = userFollowingListCollection
                            .document(currentUserId)
                            .collection("UserFollowing")
                            .whereField("user_id", isEqualTo: userId)
            
            let results = try await query.getDocuments()
            return results.isEmpty ? false : true
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func unfollowUser(currentUserId: String, userId: String) async throws {
        do {
            let currentUserFollowingSnapshot = userFollowingListCollection
                            .document(currentUserId)
                            .collection("UserFollowing")
                            .whereField("user_id", isEqualTo: userId)
            
            let docs = try await currentUserFollowingSnapshot.getDocuments()
            
            for result in docs.documents {
                try await result.reference.delete()
            }
            
            let otherUserFollowingSnapshot = userFollowingListCollection
                            .document(userId)
                            .collection("UserFollowers")
                            .whereField("user_id", isEqualTo: currentUserId)
            
            let docsTwo = try await otherUserFollowingSnapshot.getDocuments()
            
            for result in docsTwo.documents {
                try await result.reference.delete()
            }
            
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func checkUserFollowRequest(currentUserId: String, userId: String) async throws -> Bool {
        let query = userFollowRequestCollection
                        .whereField("current_user_id", isEqualTo: currentUserId)
                        .whereField("request_to_follow_user_id", isEqualTo: userId)
        
        do {
            let results = try await query.getDocuments()
            return results.isEmpty ? false : true
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func confirmUserFollowRequest(currentUserId: String, userId: String) async throws {
        let query = userFollowRequestCollection
                        .whereField("current_user_id", isEqualTo: userId)
                        .whereField("request_to_follow_user_id", isEqualTo: currentUserId)
        
        do {
            let results = try await query.getDocuments()
            for result in results.documents {
                try await result.reference.updateData(["accepted": true])
                try await addUserToFollowingList(currentUserId: currentUserId, userId: userId)
                try await addUserToFollowerList(currentUserId: currentUserId, userId: userId)
                try await deleteUserFollowRequest(currentUserId: userId, userId: currentUserId)
            }
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func addUserToFollowingList(currentUserId: String, userId: String) async throws {
        let docData: [String : Any] = [
            "user_id" : currentUserId,
        ]
        try await userFollowingListCollection
            .document(userId)
            .collection("UserFollowing")
            .addDocument(data: docData)
    }
    
    func addUserToFollowerList(currentUserId: String, userId: String) async throws {
        let docData: [String : Any] = [
            "user_id" : userId,
        ]
        try await userFollowingListCollection
            .document(currentUserId)
            .collection("UserFollowers")
            .addDocument(data: docData)
    }
    
    func deleteUserFollowRequest(currentUserId: String, userId: String) async throws {
        let query = userFollowRequestCollection
                        .whereField("current_user_id", isEqualTo: currentUserId)
                        .whereField("request_to_follow_user_id", isEqualTo: userId)
        
        do {
            let results = try await query.getDocuments()
            for result in results.documents {
                try await result.reference.delete()
            }
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func getUserNotifications(currentUserId: String) async throws -> [Notification] {
        let query = userFollowRequestCollection
                        .whereField("request_to_follow_user_id", isEqualTo: currentUserId)
                        .order(by: "date_created", descending: true)
        
        do {
            let results = try await query.getDocuments()
            var notiResults: [Notification] = []
            for result in results.documents {
                let requestFollowUserId = result["current_user_id"] as? String ?? ""
                let userData = try await UserManager.shared.getUser(userId: requestFollowUserId)
                
                if let user = userData {
                    let displayName = user.displayname ?? ""
                    let username = user.username ?? ""
                    let hashcode = user.hashcode ?? ""
                    var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                    if let photoUrl = user.photoUrl {
                        profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                    }
                    
                    let newNoti = Notification(
                        userId: requestFollowUserId,
                        displayName: displayName,
                        username: username,
                        hashcode: hashcode,
                        profileImage: profileImage,
                        action: .follewRequest
                    )
                    notiResults.append(newNoti)
                }
            }
            
            return notiResults
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func removeFollower(currentUserId: String, userId: String) async throws {
        let query = userFollowingListCollection
                            .document(currentUserId)
                            .collection("UserFollowers")
                            .whereField("user_id", isEqualTo: userId)
        
        let queryTwo = userFollowingListCollection
                            .document(userId)
                            .collection("UserFollowing")
                            .whereField("user_id", isEqualTo: currentUserId)
        do {
            let results = try await query.getDocuments()
            for result in results.documents {
                try await result.reference.delete()
            }
            
            let resultsTwo = try await queryTwo.getDocuments()
            for result in resultsTwo.documents {
                try await result.reference.delete()
            }
        } catch {
            throw URLError(.badServerResponse)
        }
    }
}
