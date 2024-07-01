//
//  LibraryWantToReadView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/24/23.
//

import SwiftUI

//struct LibraryWantToReadView: View {
//    @ObservedObject var viewModel: LibraryViewModel
//    
//    var body: some View {
//        ZStack {
//            ScrollView {
//              LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
//                  ForEach(viewModel.booksWantToRead) { book in
//                      NavigationLink {
//                          BookView(book: book)
//                      } label: {
//                          AsyncImage(url: URL(string: book.coverURL)) { image in
//                              image
//                                  .resizable()
//                                  .frame(width: 85, height: 125)
//                                  .shadow(radius: 10)
//
//                          } placeholder: {
//                              ProgressView()
//                          }
//                      }
//                  }
//              }
//          }
//        }
//    }
//}

//struct LibraryWantToReadView_Previews: PreviewProvider {
//    static var previews: some View {
//        LibraryWantToReadView()
//    }
//}
