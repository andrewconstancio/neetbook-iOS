//
//  BookshelfBookView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/14/24.
//

import SwiftUI

struct BookshelfBookView: View {
    let book: Book
    var body: some View {
        NavigationLink {
            BookView(book: book)
        } label: {
            if let coverPhoto = book.coverPhoto {
                Image(uiImage: coverPhoto)
                    .resizable()
                    .frame(width: 85, height: 125)
                    .shadow(radius: 10)
                    .cornerRadius(5)
            }
        }

    }
}

//#Preview {
//    BookshelfBookView()
//}
