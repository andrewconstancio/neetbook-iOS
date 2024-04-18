//
//  ProfileFavoritesView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/8/24.
//

import SwiftUI

struct ProfileFavoritesView: View {
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    var body: some View {
        if viewModel.favoriteBooks.count > 0 {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(viewModel.favoriteBooks) { favbook in
                    NavigationLink {
                        BookView(book: favbook.book)
                    } label: {
                        AsyncImage(url: URL(string: favbook.book.coverURL)) { image in
                            image
                                .resizable()
                                .frame(width: 85, height: 125)
                                .shadow(radius: 10)
                                .cornerRadius(10)
                            
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
        } else {
            VStack {
                Text("No books added yet!")
                    .foregroundColor(.white.opacity(0.7))
                    .fontWeight(.bold)
                Spacer()
                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    ProfileFavoritesView()
}
