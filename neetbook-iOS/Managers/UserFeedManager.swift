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

struct PostFeedInstance {
    let action: String
    let user: DBUser
    let profilePicture: UIImage
    let book: Book
    var dateEvent: Date
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: dateEvent)
   }
}

final class UserFeedManager {
    static var shared = UserFeedManager()
    
    private let followingListCollection = Firestore.firestore().collection("UserFollowList")
    private let actionCollection = Firestore.firestore().collection("BookActions")
    
    func getUserHomeFeed(userId: String) async throws -> [PostFeedInstance] {
        do {
            let followQ = followingListCollection
                            .document(userId)
                            .collection("UserFollowing")
            
            let results = try await followQ.getDocuments()
            let userIdList = results.documents.compactMap { $0["user_id"] as? String }
        
            var postList: [PostFeedInstance] = []
            
            if userIdList.count > 0 {
                let actionQ = actionCollection
                    .whereField("user_id", in: userIdList)
                    .limit(to: 10)
                    .order(by: "date_created", descending: true)
                
                let actionResults = try await actionQ.getDocuments()
            
                try await withThrowingTaskGroup(of: PostFeedInstance?.self) { group in
                    for result in actionResults.documents {
                        group.addTask {
                            let data = result.data()
                            let userId = data["user_id"] as? String ?? ""
                            let action = data["action"] as? String ?? ""
                            let bookId = data["book_id"] as? String ?? ""
                            let dateCreated = (data["date_created"] as? Timestamp)?.dateValue() ?? Date()
                            let user = try await UserManager.shared.getUser(userId: userId)
                            let bookData = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
                            var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                            if let photoUrl = user.photoUrl {
                                profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                            }
                            
                            var actionText = ""
                            
                            if action == "Reading" {
                                actionText = "started reading"
                            } else if action == "Want To Read" {
                                actionText = "wants to read"
                            } else if action == "Read" {
                                actionText = "finished!"
                            }
                            
                            guard let book = bookData else {  return nil }
    
                            return PostFeedInstance(
                                action: actionText,
                                user: user,
                                profilePicture: profileImage,
                                book: book,
                                dateEvent: dateCreated
                            )
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
            
            return postList
        } catch {
            throw error
        }
    }
    
    func getUserActivty(userId: String) async throws -> [PostFeedInstance] {
        do {
            let actionQ = actionCollection
                .whereField("user_id", isEqualTo: userId)
                .limit(to: 10)
                .order(by: "date_created", descending: true)
            
            let actionResults = try await actionQ.getDocuments()
        
            return try await withThrowingTaskGroup(of: PostFeedInstance?.self) { group in
                var postList: [PostFeedInstance] = []
                
                for result in actionResults.documents {
                    group.addTask {
                        let data = result.data()
                        let userId = data["user_id"] as? String ?? ""
                        let action = data["action"] as? String ?? ""
                        let bookId = data["book_id"] as? String ?? ""
                        let dateCreated = (data["date_created"] as? Timestamp)?.dateValue() ?? Date()
                        let user = try await UserManager.shared.getUser(userId: userId)
                        let bookData = try await BookDataService.shared.fetchBookInfo(bookId: bookId)
                        var profileImage: UIImage = UIImage(imageLiteralResourceName: "circle-user-regular")
                        if let photoUrl = user.photoUrl {
                            profileImage = try await UserManager.shared.getURLImageAsUIImage(path: photoUrl)
                        }
                        
                        var actionText = ""
                        
                        if action == "Reading" {
                            actionText = "Started reading"
                        } else if action == "Want To Read" {
                            actionText = "Wants to read"
                        } else if action == "Read" {
                            actionText = "Finished!"
                        }
                        
                        guard let book = bookData else { return nil }

                        return PostFeedInstance(
                            action: actionText,
                            user: user,
                            profilePicture: profileImage,
                            book: book,
                            dateEvent: dateCreated
                        )
                    }
                }
                
                for try await post in group {
                    if let post = post {
                        postList.append(post)
                    }
                }
                
                postList.sort { $0.dateEvent > $1.dateEvent }
                
                return postList
            }
        } catch {
            throw error
        }
    }
}
