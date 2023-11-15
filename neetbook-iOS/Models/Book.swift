//
//  Book.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI


struct Book: Identifiable, Codable {
    var id = UUID()
    let bookId: String
    let title: String
    let author: String
    let coverURL: String
    let description: String
    let pageCount: Int
    let categories: [String]
    var userAction: String?
    @CodableImage var coverPhoto: UIImage?
    
    mutating func setUserAction(action: String) {
        self.userAction = action
    }
}
