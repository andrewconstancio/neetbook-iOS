//
//  PopularBookFullView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/21/24.
//

import SwiftUI
import Shimmer

struct PopularBookFullView: View {
    let name: String
    let listName: String
    @State private var books: [Book] = []
    @State private var isLoadingBooks: Bool = false
    
    @ObservedObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack {
            if isLoadingBooks {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(1..<16, id: \.self) { _ in
                            Rectangle()
                                .frame(width: 100, height: 150)
                                .cornerRadius(5)
                                .shadow(radius: 8)
                                .redacted(reason: .placeholder)
                                .shimmering()
                                .opacity(0.5)
                                .padding()
                        }
                    }
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(books) { book in
                            NavigationLink {
                                BookView(book: book)
                            } label: {
                                VStack(spacing: 5) {
                                    if let coverPhoto = book.coverPhoto {
                                        Image(uiImage: coverPhoto)
                                            .resizable()
                                            .frame(width: 100, height: 150)
                                            .cornerRadius(5)
                                            .shadow(radius: 3)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
        .scrollIndicators(.hidden)
        .padding()
        .navigationTitle(name)
        .onAppear {
            Task {
                do {
                    isLoadingBooks = true
                    books = try await homeViewModel.getNYTBooks(for: listName)
                    isLoadingBooks = false
                } catch {
                    isLoadingBooks = false
                    print(error.localizedDescription)
                }
            }
        }
    }
}

//#Preview {
//    PopularBookFullView()
//}
