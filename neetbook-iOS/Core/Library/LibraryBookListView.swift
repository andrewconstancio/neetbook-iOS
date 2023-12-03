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
        ScrollView {
            VStack {
                if (bookList.count > 0) {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(bookList) { book in
                            NavigationLink {
                                BookView(book: book)
                            } label: {
                                AsyncImage(url: URL(string: book.coverURL)) { image in
                                    image
                                        .resizable()
                                        .frame(width: 85, height: 135)
                                        .cornerRadius(10)
                                        .shadow(radius: 10)
                                    
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("No books added yet!")
                                .foregroundColor(.black.opacity(0.7))
                                .fontWeight(.bold)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .padding(.bottom, 120)
        }
    }
}
