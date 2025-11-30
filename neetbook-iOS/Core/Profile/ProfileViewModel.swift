//
//  ProfileViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/15/23.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ProfileViewModel: ObservableObject {
    
    /// The user id to fetch data for.
    var userID: String
    
    /// The `DBUser` object fetched for the userID passed in.
    @Published private(set) var user: DBUser? = nil
    
    /// Flag if the data is loading.
    @Published var isLoading = false
    
    /// An array of `FavoriteBook` for the user.
    @Published var favoriteBooks: [FavoriteBook] = []
    
    /// An array of `PostFeedInstance` for this user.
    @Published var activity: [PostFeedInstance] = []
    
    /// The following count for this user.
    @Published var followingCount = 0
    
    /// The follower count for this user.
    @Published var followerCount = 0
    
    /// The following status of the user if the user in not on there own profile.
    @Published var followingStatus: FollowingStatus = .notFollowing
    
    /// An array of `MarkedBook` that is user has marked as finished.
    @Published var finishedBooks: [MarkedBook] = []
    
    /// The last activity document `DocumentSnapshot` used for pagination.
    var activitiesLastDocument: DocumentSnapshot? = nil
    
    /// The `BookUserActionManager` for this view model.
    private var bookUserActionManager = BookUserActionManager()
    
    
    /// Inititalizer for this view model.
    /// - Parameter userId: The user id to fetch the data for.
    init(userID: String) {
        self.userID = userID
        fetchData()
    }
    
    
    /// Calls all the data functions needed.
    func fetchData() {
        Task {
            isLoading = true
            await fetchUser()
            await fetchUserActivity()
            await fetchFavoriteBooks()
            await fetchUserFollowingCount()
            await fetchUserFollowerCount()

            if let user = user {
                if !user.isCurrentUser {
                    await checkUserFollowing()
                }
            }
            isLoading = false
        }
    }
    
    /// Fetches the user data.
    func fetchUser() async {
        do {
            self.user = try await UserManager.shared.getUser(userId: userID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Fetches the following count.
    func fetchUserFollowingCount() async {
        do {
            followingCount = try await UserManager.shared.getFollowingCount(userId: userID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Fetches the follower count.
    func fetchUserFollowerCount() async {
        do {
            followerCount = try await UserManager.shared.getFollowerCount(userId: userID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Fetches the users activities.
    func fetchUserActivity() async {
        do {
            let (activities, lastDocument) = try await UserFeedManager
                .shared
                .getUserActivities(userId: userID, lastDocument: activitiesLastDocument)
            activity.append(contentsOf: activities)
            activitiesLastDocument = lastDocument
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Fetches the users favorited books.
    func fetchFavoriteBooks() async {
        do {
            favoriteBooks = try await BookUserManager.shared.getFavoriteBooks(userId: userID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Check if a user is following another user.
    func checkUserFollowing() async {
        do {
            let result = try await UserInteractions.shared.checkFollowingStateFor(userID: userID)
            if result {
                followingStatus = .following
            } else {
                await checkUserFollowRequest()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Checks if there is a follow request.
    func checkUserFollowRequest() async {
        do {
            let result = try await UserInteractions.shared.checkForFollowRequest(userID: userID)
            followingStatus = result ? .requestedToFollow : followingStatus
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Sends a follow request.
    func requestToFollow() async {
        do {
            try await UserInteractions.shared.insertFollowRequest(userID: userID)
            followingStatus = .requestedToFollow
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Unfollowers a user.
    func unfollowUser() async {
        do {
            try await UserInteractions.shared.unfollow(userId: userID)
            followingStatus = .notFollowing
            followerCount -= 1
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Deletes a follow request.
    func deleteFollowRequest() async {
        do {
            try await UserInteractions.shared.deleteFollowRequest(userID: userID)
            followingStatus = .notFollowing
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Fetches an array of finished books by the user.
    func fetchFinishedBooks() async {
        do {
            finishedBooks = try await bookUserActionManager.getMarkedBookTypes(userId: userID, markedType: .finished)
            
            print(finishedBooks)
        } catch{
            print(error.localizedDescription)
        }
    }
}
