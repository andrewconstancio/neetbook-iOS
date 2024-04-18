//
//  GenreContentViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/3/24.
//

import SwiftUI

class GenreContentViewModel: ObservableObject {
    @Published var genre: String = ""
    @Published var books: [Book] = []
    
    init(genre: String) {
        Task {
            try? await getBookForGenre(for: genre)
        }
    }
    
    func getBookForGenre(for genre: String) async throws {
        print(genre)
    }
}
