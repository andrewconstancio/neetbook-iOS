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
    var pages: Int
    let publishedYear: String
    let language: String
    let publisher: String
    
    @CodableImage var coverPhoto: UIImage?
}
