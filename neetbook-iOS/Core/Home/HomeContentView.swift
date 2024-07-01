//
//  HomeContentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 3/31/24.
//

import SwiftUI
import Shimmer

struct HomeContentView: View {
    
    let name: String
    
    let listName: String
    
    let books: [Book]
    
    @Binding var isLoading: Bool
    
    @ObservedObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink {
                PopularBookFullView(name: name, listName: listName, homeViewModel: homeViewModel)
            } label: {
                HStack {
                    Text(name)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .bold()
                    Spacer()
                    Text("View all")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .bold()
                        .padding(.leading, 3)
                    
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 1)
                }
            }
            
            if isLoading {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                    ForEach(1..<4, id: \.self) { _ in
                        Rectangle()
                            .frame(width: 120, height: 170)
//                            .cornerRadius(5)
                            .shadow(radius: 8)
                            .redacted(reason: .placeholder)
                            .shimmering()
                            .opacity(0.5)
                            .padding()
                    }
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                    ForEach(books) { book in
                        NavigationLink {
                            BookView(book: book)
                        } label: {
                            VStack(spacing: 5) {
                                if let coverPhoto = book.coverPhoto {
                                    Image(uiImage: coverPhoto)
                                        .resizable()
                                        .frame(width: 120, height: 170)
//                                        .cornerRadius(5)
                                        .shadow(radius: 8)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }
}
