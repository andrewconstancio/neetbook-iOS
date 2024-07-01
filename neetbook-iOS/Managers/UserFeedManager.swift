//
//  UserFeedManager.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/21/23.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PostFeedInstance: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let documentID: String
    let user: DBUser
    let profilePicture: UIImage
    let book: Book
    var dateEvent: Date
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: dateEvent)
   }
    
    var currentUserLikedPost: Bool
    
    mutating func setUserliked(value: Bool) {
        currentUserLikedPost = value
    }
}

final class UserFeedManager {
    static var shared = UserFeedManager()
    
    private let commentsCollecion = Firestore.firestore().collection("BookComments")
    private let postCollection = Firestore.firestore().collection("UserPost")
    private let followingListCollection = Firestore.firestore().collection("UserFollowList")
    private let actionCollection = Firestore.firestore().collection("BookActions")
    private let userBookshelvesAddedTo = Firestore.firestore().collection("userBookshelvesAddedTo")
    private let userMarkedBooks = Firestore.firestore().collection("userMarkedBooks")
    
    
    func buildPostInstance(result: DocumentSnapshot) async throws -> PostFeedInstance? {
        let data = result.data()
        let collection = data?["collection"] as? String ?? ""
        let userId = data?["user_id"] as? String ?? ""
        let bookId = data?["book_id"] as? String ?? ""
        let documentId = data?["document_id"] as? String ?? ""
        
        let currentUserLikedPost = try await UserPostManager.shared.checkPostLiked(documentId: documentId)
        
        switch(collection) {
        case "userBookshelvesAddedTo":
            let snapshot = self.userBookshelvesAddedTo
                        .document(documentId)
            
            let data = try await snapshot.getDocument().data()
            let dateCreated = (data?["date_created"] as? Timestamp)?.dateValue() ?? Date()
            let bookData = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
            var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
            let userData = try await UserManager.shared.getUser(userId: userId)
    
            guard let user = userData else {
                return nil
            }

            if let photoUrl = user.photoUrl {
                profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
            }

            let actionText = "Added to shelf"
            guard let book = bookData else {
                return nil
            }

            return PostFeedInstance(
                title: actionText,
                content: "",
                documentID: result.documentID,
                user: user,
                profilePicture: profileImage,
                book: book,
                dateEvent: dateCreated,
                currentUserLikedPost: currentUserLikedPost
            )
        case "BookComments":
            let snapshot = self.commentsCollecion
                        .document(bookId)
                        .collection("comments")
                        .document(documentId)
            
            let data = try await snapshot.getDocument().data()
            
            
            let comment = data?["comment"] as? String ?? ""
            let dateCreated = (data?["date_created"] as? Timestamp)?.dateValue() ?? Date()
            let bookData = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
            var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
            let userData = try await UserManager.shared.getUser(userId: userId)

            guard let user = userData else {
                return nil
            }

            if let photoUrl = user.photoUrl {
                profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
            }

            guard let book = bookData else {  return nil }

            return PostFeedInstance(
                title: "Left a note 📝",
                content: comment,
                documentID: result.documentID,
                user: user,
                profilePicture: profileImage,
                book: book,
                dateEvent: dateCreated,
                currentUserLikedPost: currentUserLikedPost
            )
        case "userMarkedBooks":
            let snapshot = userMarkedBooks.document(documentId)
            
            let data = try await snapshot.getDocument().data()
            
            let dateCreated = (data?["date_created"] as? Timestamp)?.dateValue() ?? Date()
            let bookData = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
            var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
            let userData = try await UserManager.shared.getUser(userId: userId)
            let markType = data?["mark_type"] as? String ?? ""

            guard let user = userData else {
                return nil
            }

            if let photoUrl = user.photoUrl {
                profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
            }

            guard let book = bookData else {  return nil }

            return PostFeedInstance(
                title: markType.capitalizeFirstLetter() + "!" + " ✅",
                content: "",
                documentID: result.documentID,
                user: user,
                profilePicture: profileImage,
                book: book,
                dateEvent: dateCreated,
                currentUserLikedPost: currentUserLikedPost
            )
        default:
            return nil
        }
    }
    
    func getUserHomeFeed(userId: String, lastDocument: DocumentSnapshot?) async throws -> ([PostFeedInstance], DocumentSnapshot?) {
        do {
            
            let followQ = followingListCollection
                            .document(userId)
                            .collection("UserFollowing")
            
            let results = try await followQ.getDocuments()
            let userIdList = results.documents.compactMap { $0["user_id"] as? String }
        
            var postList: [PostFeedInstance] = []
            var lastDocumentSnapshot: DocumentSnapshot? = nil
            
            if userIdList.count > 0 {
                var actionQ: Query
                if let lastDocument {
                    actionQ = postCollection
                        .whereField("user_id", in: userIdList)
                        .limit(to: 8)
                        .order(by: "date_created", descending: true)
                        .start(afterDocument: lastDocument)
                } else {
                    actionQ = postCollection
                        .whereField("user_id", in: userIdList)
                        .order(by: "date_created", descending: true)
                        .limit(to: 8)
                }
                
                let actionResults = try await actionQ.getDocuments()
                lastDocumentSnapshot = actionResults.documents.last
                
//                print("NIRPRJmPAmURPI7tG52v: \(lastDocumentSnapshot?.documentID)")
            
                try await withThrowingTaskGroup(of: PostFeedInstance?.self) { group in
                    for result in actionResults.documents {
                        group.addTask {
                            let post = try await self.buildPostInstance(result: result)
                            return post
                        }
                    }
                    
                    for try await post in group {
                        if let post = post {
                            postList.append(post)
                        }
                    }
                    
                    postList.sort { $0.dateEvent > $1.dateEvent }
                }
            }
            
            return (postList, lastDocumentSnapshot)
        } catch {
            throw error
        }
    }
    
    func refreshUserFeed(userId: String, firstDocumentId: String, lastDocument: DocumentSnapshot? = nil) async throws -> [PostFeedInstance] {
        var posts: [PostFeedInstance] = []
        
        let followQ = followingListCollection
                        .document(userId)
                        .collection("UserFollowing")
        
        let results = try await followQ.getDocuments()
        let userIdList = results.documents.compactMap { $0["user_id"] as? String }
        
        var query = postCollection
            .order(by: "date_created", descending: true)
            .whereField("user_id", in: userIdList)
            .limit(to: 10)
        
        if let lastDocument = lastDocument {
             query = query.start(afterDocument: lastDocument) // Start after the last document retrieved
         }
        
        let querySnapshot = try await query.getDocuments()
        let documents = querySnapshot.documents
    
        
        let foundFirstDocument = documents.first(where: { $0.documentID == firstDocumentId })
        
        for result in documents {
            if result.documentID == firstDocumentId {
                return posts
            }
    
            let newPost = try await buildPostInstance(result: result)
            if let post = newPost {
                posts.append(post)
            }
        }
        
        if !posts.isEmpty {
            let lastDocumentSnapshot = querySnapshot.documents.last
            let morePosts = try await refreshUserFeed(userId: userId, firstDocumentId: firstDocumentId, lastDocument: lastDocumentSnapshot)
            posts += morePosts
        }
        
        return posts
    }
    
    func getUserActivities(userId: String, lastDocument: DocumentSnapshot?) async throws -> ([PostFeedInstance], DocumentSnapshot?) {
        var lastDocumentSnapshot: DocumentSnapshot? = nil
        var actionQ: Query
        
        print("last: \(lastDocument?.documentID)")
        
        if let lastDocument {
            actionQ = postCollection
                .order(by: "date_created", descending: true)
                .whereField("user_id", isEqualTo: userId)
                .limit(to: 8)
                .start(afterDocument: lastDocument)
        } else {
            actionQ = postCollection
                .order(by: "date_created", descending: true)
                .whereField("user_id", isEqualTo: userId)
                .limit(to: 8)
        }
        
        var postList: [PostFeedInstance] = []
        let actionResults = try await actionQ.getDocuments()
        lastDocumentSnapshot = actionResults.documents.last
        
        try await withThrowingTaskGroup(of: PostFeedInstance?.self) { group in
            for result in actionResults.documents {
                group.addTask {
                    let post = try await self.buildPostInstance(result: result)
                    return post
                }
            }
            
            for try await post in group {
                if let post = post {
                    postList.append(post)
                }
            }
            
            postList.sort { $0.dateEvent > $1.dateEvent }
        }
        
        return (postList, lastDocumentSnapshot)
    }
}
