//
//  LibraryBookListView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/3/23.
//

import SwiftUI

struct LibraryBookListView: View {
    let bookList: [Book]
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                    ForEach(bookList) { book in
                        NavigationLink {
                            BookView(book: book)
                        } label: {
                            AsyncImage(url: URL(string: book.coverURL)) { image in
                                image
                                    .resizable()
                                    .frame(width: 85, height: 125)
                                    .shadow(radius: 10)
                                
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
    }
}

//struct LibraryBookListView: PreviewProvider {
//    static var previews: some View {
//        LibraryBookListView(bookList: [])
//    }
//}
