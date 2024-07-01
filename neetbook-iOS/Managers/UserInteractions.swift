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

enum NotificationType {
    case followAccepted
    case followSent
    case newPostComment
    case requestedToFollow
    case likedActivity
}

enum FollowingStatus {
    case notFollowing
    case requestedToFollow
    case following
}

struct UserNotification: Identifiable {
    var id = UUID()
    let userId: String
    var type: NotificationType
    let displayName: String
    var message: String
    let dateCreated: Date
    var followStatus: FollowingStatus
    var comment: String?
    var profilePicture: UIImage
    var post: PostFeedInstance?
}

final class UserInteractions {
    
    static let shared = UserInteractions()
    
    private let userCollection = Firestore.firestore().collection("users")
    private let userFollowRequestCollection = Firestore.firestore().collection("UserFollowRequest")
    private let userFollowingListCollection = Firestore.firestore().collection("UserFollowList")
    private let userNotificationListCollection = Firestore.firestore().collection("UserNotifications")
    private let postCollectionComments = Firestore.firestore().collection("UserPostComments")
    private let postCollection = Firestore.firestore().collection("UserPost")
    
    private let helper = Helpers()
    
    func searchForUser(searchText: String, currentUserId: String) async throws -> [UserSearchResult] {
        let usernameQuery = userCollection
            .whereField("username", isEqualTo: searchText.lowercased())
            .whereField("user_id", isNotEqualTo: currentUserId)
        
        let displayNameQuery = userCollection
            .whereField("displayname", isEqualTo: searchText)
            .whereField("user_id", isNotEqualTo: currentUserId)
        
        let usernameResultData = try await usernameQuery.getDocuments()
        let displaynameResultData = try await displayNameQuery.getDocuments()
        
        var resultUserIds: [String] = []
        for doc in usernameResultData.documents {
            let userId = doc["user_id"] as? String ?? ""
            resultUserIds.append(userId)
        }
        for doc in displaynameResultData.documents {
            let userId = doc["user_id"] as? String ?? ""
            resultUserIds.append(userId)
        }
        
        if resultUserIds.isEmpty {
            return []
        }
        
        let combinedUserQuery = userCollection
            .whereField("user_id", in: resultUserIds)
        
        let combinedUserData = try await combinedUserQuery.getDocuments()
        
        var searchUsers: [UserSearchResult] = []
        for document in combinedUserData.documents {
            let user_id = document["user_id"] as? String ?? ""
            let name = document["displayname"] as? String ?? ""
            let username = document["username"] as? String ?? ""
            let hashcode = document["hashcode"] as? String ?? ""
            let photoURL = document["photo_url"] as? String ?? ""
             
            if let url = URL(string: photoURL) {
                let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
                let image = helper.convertDataToUIImage(data: data, response: response)
                
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
    
    func addToNotificationFollow(type: String, currentUserId: String, userId: String) async throws {
        let userData = try await userCollection.document(userId).getDocument()
        let checkFollowingData = try await userFollowingListCollection
                                    .document(currentUserId)
                                    .collection("UserFollowing")
                                    .whereField("user_id", isEqualTo: userId)
                                    .getDocuments()
        
        let isFollowing = !checkFollowingData.isEmpty
        
        let name = userData["displayname"] as? String ?? ""
        let userProfilePic = userData["photo_url"] as? String ?? ""
        
        let docData: [String : Any] = [
            "user_id" : userId,
            "action_user_id" : currentUserId,
            "display_name" : name,
            "photo_url" : userProfilePic,
            "type" : type,
            "is_following" : isFollowing,
            "date_created" : Timestamp(date: Date())
        ]
        
        try await userNotificationListCollection
            .document(currentUserId)
            .collection("notifications")
            .addDocument(data: docData)
    }
    
    func addToNotificationComment(postDocumentId: String, commentDocumentId: String, comment: String, currentUserId: String, userId: String) async throws {
        
        let userData = try await userCollection.document(userId).getDocument()
        let checkFollowingData = try await userFollowingListCollection
                                    .document(currentUserId)
                                    .collection("UserFollowing")
                                    .whereField("user_id", isEqualTo: userId)
                                    .getDocuments()
        
        let isFollowing = !checkFollowingData.isEmpty
        
        let name = userData["displayname"] as? String ?? ""
        let userProfilePic = userData["photo_url"] as? String ?? ""
        
        let docData: [String : Any] = [
            "user_id" : userId,
            "action_user_id" : currentUserId,
            "display_name" : name,
            "photo_url" : userProfilePic,
            "type" : "Post Comment",
            "post_document_id" : postDocumentId,
            "comment_document_id" : commentDocumentId,
            "comment" : comment,
            "is_following" : isFollowing,
            "date_created" : Timestamp(date: Date())
        ]
        
        print(userId)
        
        try await userNotificationListCollection
            .document(userId)
            .collection("notifications")
            .addDocument(data: docData)
    }
    
    func addToNotificationLike(for post: PostFeedInstance) async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        let user = try await UserManager.shared.getUser(userId: currentUserId)
        let isFollowing = try await checkUserFollowing(currentUserId: currentUserId, userId: post.user.userId)
        
        let docData: [String : Any] = [
            "user_id" : post.user.userId,
            "action_user_id" : currentUserId,
            "display_name" : user?.displayname as String? ?? "",
            "photo_url" : user?.photoUrl as String? ?? "",
            "type" : "Like Post",
            "post_document_id" : post.documentID,
            "is_following" : isFollowing,
            "date_created" : Timestamp(date: Date())
        ]
        
        try await userNotificationListCollection
            .document(post.user.userId)
            .collection("notifications")
            .addDocument(data: docData)
    }
    
    func requestToFollow(currentUserId: String, userId: String) async throws {
        let docData: [String : Any] = [
            "user_id" : userId,
            "requested_to_follow_user_id" : currentUserId,
            "accepted" : false,
            "date_created" : Timestamp(date: Date())
        ]
        
        try await userFollowRequestCollection
            .document(userId)
            .collection("request")
            .addDocument(data: docData)
    
        try await addToNotificationFollow(type: "Requested To Follow", currentUserId: userId, userId: currentUserId)
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
        
        
        try await self.removeNotificationFollow(type: "Follow Accepted", removeOnUserId: userId, actionUserID: currentUserId)
    }
    
    func checkUserFollowRequest(currentUserId: String, userId: String) async throws -> Bool {
        let query = userFollowRequestCollection
                        .document(userId)
                        .collection("request")
                        .whereField("user_id", isEqualTo: userId)
                        .whereField("requested_to_follow_user_id", isEqualTo: currentUserId)
        
        let results = try await query.getDocuments()
        return results.isEmpty ? false : true
    }
    
    func confirmUserFollowRequest(currentUserId: String, userId: String) async throws {
        let query = userFollowRequestCollection
                        .document(currentUserId)
                        .collection("request")
                        .whereField("user_id", isEqualTo: currentUserId)
                        .whereField("requested_to_follow_user_id", isEqualTo: userId)
        
        let results = try await query.getDocuments()
        for result in results.documents {
            try await result.reference.updateData(["accepted": true])
            try await addUserToFollowingList(currentUserId: currentUserId, userId: userId)
            try await addUserToFollowerList(currentUserId: currentUserId, userId: userId)
            try await deleteUserFollowRequest(currentUserId: userId, userId: currentUserId)
        }
        
        try await addToNotificationFollow(type: "Follow Accepted", currentUserId: currentUserId, userId: userId)
    }
    
    func getUserNotifications(userId: String) async throws -> [UserNotification] {
        let query = try await userNotificationListCollection
                    .document(userId)
                    .collection("notifications")
                    .limit(to: 20)
                    .order(by: "date_created", descending: true)
                    .getDocuments()
                                
        var notifications: [UserNotification] = []
        try await withThrowingTaskGroup(of: UserNotification?.self) { group in
            for data in query.documents {
                group.addTask {
                    let otherUserId = data["action_user_id"] as? String ?? ""
                    let otherUser = try await UserManager.shared.getUser(userId: otherUserId)
                    let displayName = otherUser?.displayname ?? "Deleted User"
                    let type = data["type"] as? String ?? ""
                    let photoURL = data["photo_url"] as? String ?? ""
                    let comment = data["comment"] as? String ?? ""
                    let postDocumentId = data["post_document_id"] as? String ?? ""
                    let dateCreated = (data["date_created"] as? Timestamp)?.dateValue() ?? Date()
                    let isFollowing = try await self.checkUserFollowing(currentUserId: userId, userId: otherUserId)
                    let profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoURL)
                    let followRequested = try await self.checkUserFollowRequest(currentUserId: userId, userId: otherUserId)
                    
                    var followStatus: FollowingStatus = .notFollowing
                    
                    if isFollowing {
                        followStatus = .following
                    }
                    
                    if followRequested {
                        followStatus = .requestedToFollow
                    }
                    
                    switch(type) {
                    case "Follow Accepted":
                        return UserNotification(userId: otherUserId,
                                                type: .followAccepted,
                                                displayName: displayName,
                                                message: " Is now following you!",
                                                dateCreated: dateCreated,
                                                followStatus: followStatus,
                                                profilePicture: profileImage)
                    case "Post Comment":
                        let post = try await UserPostManager.shared.getPost(documentID: postDocumentId)
                        return UserNotification(userId: otherUserId,
                                                type: .newPostComment,
                                                displayName: displayName,
                                                message: " Left a comment on your activity",
                                                dateCreated: dateCreated,
                                                followStatus: followStatus,
                                                comment: comment,
                                                profilePicture: profileImage,
                                                post: post)
                    case "Requested To Follow":
                        return UserNotification(userId: otherUserId,
                                                type: .requestedToFollow,
                                                displayName: displayName,
                                                message: " Requested to follow you",
                                                dateCreated: dateCreated,
                                                followStatus: followStatus,
                                                profilePicture: profileImage)
                    case "Like Post":
                        let post = try await UserPostManager.shared.getPost(documentID: postDocumentId)
                        return UserNotification(userId: otherUserId,
                                                    type: .likedActivity,
                                                    displayName: displayName,
                                                    message: " Liked your activity",
                                                    dateCreated: dateCreated,
                                                    followStatus: followStatus,
                                                    profilePicture: profileImage,
                                                    post: post)
                    default:
                        return nil
                    }
                }
            }
            
            for try await notification in group {
                if let notification = notification {
                    notifications.append(notification)
                }
            }
            
            notifications.sort { $0.dateCreated > $1.dateCreated }

        }
        return notifications
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
                        .document(userId)
                        .collection("request")
                        .whereField("user_id", isEqualTo: userId)
                        .whereField("requested_to_follow_user_id", isEqualTo: currentUserId)
        
        do {
            let results = try await query.getDocuments()
            for result in results.documents {
                try await result.reference.delete()
            }
            
            try await self.removeNotificationFollow(type: "Requested To Follow", removeOnUserId: userId, actionUserID: currentUserId)
        } catch {
            throw URLError(.badServerResponse)
        }
    }
    
    func getUserFollowRequest(currentUserId: String) async throws -> [FollowRequest] {
        let query = userFollowRequestCollection
                        .document(currentUserId)
                        .collection("request")
                        .whereField("user_id", isEqualTo: currentUserId)
                        .order(by: "date_created", descending: true)
        
        do {
            let results = try await query.getDocuments()
            var notiResults: [FollowRequest] = []
            for result in results.documents {
                let requestFollowUserId = result["requested_to_follow_user_id"] as? String ?? ""
                let userData = try await UserManager.shared.getUser(userId: requestFollowUserId)
                
                if let user = userData {
                    let displayName = user.displayname ?? ""
                    let username = user.username ?? ""
                    let hashcode = user.hashcode ?? ""
                    var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                    if let photoUrl = user.photoUrl {
                        profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                    }
                    
                    let newNoti = FollowRequest(
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
    
    func removeNotificationFollow(type: String, removeOnUserId: String, actionUserID: String) async throws {
        let query = try await userNotificationListCollection
                        .document(removeOnUserId)
                        .collection("notifications")
                        .whereField("type", isEqualTo: type)
                        .whereField("action_user_id", isEqualTo: actionUserID)
                        .getDocuments()
        
        for result in query.documents {
            try await result.reference.delete()
        }
    }
    
    func removeNotificationPostComment(commentDocumentId: String) async throws {
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        
        let query = try await userNotificationListCollection
                        .document(currentUserId)
                        .collection("notifications")
                        .whereField("type", isEqualTo: "Post Comment")
                        .whereField("comment_document_id", isEqualTo: commentDocumentId)
                        .getDocuments()
        
        for result in query.documents {
            try await result.reference.delete()
        }
    }
    
    func getPendingFriendsCount(userId: String) async throws -> Int {
        let query = userFollowRequestCollection
                        .document(userId)
                        .collection("request")
                        .whereField("user_id", isEqualTo: userId)
        
        return try await query.getDocuments().count
    }
}
