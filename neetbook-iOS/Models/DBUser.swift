//
//  User.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/14/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct Bookshelf: Identifiable, Codable {
    var id: String
    var name: String
    var imageUrl: String
    var dateCreated: Date
    var count: Int?
    var isPublic: Bool?
    
    init(name: String, imageUrl: String, count: Int = 0, isPublic: Bool = true) {
        self.id = UUID().uuidString
        self.name = name
        self.imageUrl = imageUrl
        self.dateCreated = Date()
        self.count = count
        self.isPublic = isPublic
    }
    
    mutating func setName(name: String) {
        self.name = name
    }
    
    mutating func setImageUrl(url: String) {
        self.imageUrl = url
    }
    
    mutating func setCount(count: Int) {
        self.count = count
    }
    
    mutating func setIsPublic(isPublic: Bool) {
        self.isPublic = isPublic
    }
}

struct BookshelfAddedTo: Codable {
    let bookId: String
    let bookshelfId: String
    let dateCreated: Date
    let userId: String
}

struct DBUser: Codable {
    let userId: String
    var username: String?
    var hashcode: String?
    var displayname: String?
    let email: String?
    var photoUrl: String?
    var publicAccount: Bool = true
    var dateOfBirth: Date?
    let dateCreated: Date?
    var selectedGenres: [String]?
    
    @CodableImage var profilePhoto: UIImage?
    
    init(
        userId: String,
        hashcode: String? = nil,
        username: String? = nil,
        displayname: String? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        publicAccount: Bool = true,
        dateOfBirth: Date? = nil,
        dateCreated: Date? = nil,
        selectedGenres: [String]? = nil,
        profilePhoto: UIImage? = nil
    ) {
        self.userId = userId
        self.username = username
        self.displayname = displayname
        self.hashcode = hashcode
        self.email = email
        self.photoUrl = email
        self.publicAccount = publicAccount
        self.dateOfBirth = dateOfBirth
        self.dateCreated = dateCreated
        self.selectedGenres = selectedGenres
        self.profilePhoto = profilePhoto
    }
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.username = "user \(UUID())"
        self.hashcode = "0000"
        self.displayname = ""
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.publicAccount = true
        self.dateOfBirth = Date()
        self.dateCreated = Date()
        self.selectedGenres = []
    }
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == userId
    }
    
    mutating func setUserProfilePic(image: UIImage) {
        self.profilePhoto = image
    }
}
