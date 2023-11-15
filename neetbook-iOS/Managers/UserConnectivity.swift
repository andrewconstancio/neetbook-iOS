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
    let id: String?
    let displayName: String
    let username: String
    let hashcode: String
    let profileURL: String
    let profilePicture: UIImage
}

final class UserConnectivity {
    
    static let shared = UserConnectivity()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    func searchForUser(searchText: String) async throws -> [UserSearchResult] {
        let query = userCollection.whereField("username", isEqualTo: searchText)
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
}
