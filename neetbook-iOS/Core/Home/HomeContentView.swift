//
//  HomeContentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 3/31/24.
//

import SwiftUI

struct HomeContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Best Sellers")
                .font(.title2)
                .foregroundColor(.primary)
                .bold()
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(viewModel.popularBookResults) { book in
                    NavigationLink {
                        BookView(book: book)
                    } label: {
                        VStack(spacing: 5) {
                            if let coverPhoto = book.coverPhoto {
                                Image(uiImage: coverPhoto)
                                    .resizable()
                                    .frame(width: 100, height: 150)
                                    .cornerRadius(5)
                            }
                            
                        }
                    }
                }
            }
        }
    }
}
