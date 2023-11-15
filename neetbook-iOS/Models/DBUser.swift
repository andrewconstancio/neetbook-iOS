//
//  User.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/14/23.
//

import SwiftUI

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
        selectedGenres: [String]? = nil
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

}
