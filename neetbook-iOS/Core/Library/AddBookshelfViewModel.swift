//
//  AddBookshelfViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/8/24.
//

import SwiftUI

@MainActor
class AddBookshelfViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var coverPhoto: UIImage? = nil
    
    
    func saveBookshelf() async throws {
        try await UserManager.shared.saveUserBookshelf(name: name, coverPhoto: coverPhoto)
    }
    
    func editBookshelf(bookshelf: Bookshelf) async throws {
        try await UserManager.shared.editUserBookshelf(bookshelf: bookshelf, name: name, coverPhoto: coverPhoto)
    }
    
    func initBookshelf(bookshelf: Bookshelf) async throws {
        name = bookshelf.name
        if bookshelf.imageUrl != "" {
            let image = try await Helpers.shared.convertURLToImage(someURL: bookshelf.imageUrl)
            coverPhoto = image
        }
    }
}
