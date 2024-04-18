//
//  LibraryView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//

import SwiftUI
import PopupView
import SnapToScroll
import SwiftfulLoadingIndicators

enum BookListType {
    case reading, wantToRead, read
}

struct LibraryView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @StateObject private var viewModel = LibraryViewModel()
    
    @State var showNewBookshelfPopup: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Bookshelves")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .bold()
                
                Text(" (\(viewModel.shelves.count) shelves)")
                    .font(.caption)
                    .foregroundStyle(.primary)
                
                Spacer()
                Button {
                    showNewBookshelfPopup = true
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .bold()
                        .foregroundColor(.primary)
                        .offset(x: -10, y: 0)
                }
            }
            .padding()
            List {
                ForEach(viewModel.shelves)  { shelf in
                    HStack {
                        if shelf.imageUrl == "" {
                            NoPhotoBookshelfView(width: 20, height: 20)
                                .shadow(radius: 10)
                        } else {
                            AsyncImage(url: URL(string: shelf.imageUrl)) { image in
                                image
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .scaledToFit()
                                    .clipShape(Circle())
                                
                            } placeholder: {
                            }
                        }

                        NavigationLink {
                            BookshelfView(bookshelf: shelf)
                        } label: {
                            Text(shelf.name)
                                .bold()
                                .foregroundStyle(.primary)
                                .offset(x: 10, y: 0)
                        }
                        
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    .onAppear {
                        print(shelf.dateCreated)
                    }
                    .padding()
                    .frame(height: 85)
                    .background(Color("Background"))
                }
            }
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea(.all)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
        }
        .overlay(Color.black.opacity(showNewBookshelfPopup ? 0.3 : 0.0))
        .blur(radius: showNewBookshelfPopup ? 2 : 0)
        .popup(isPresented: $showNewBookshelfPopup) {
            AddBookshelfView(showNewBookshelfPopup: $showNewBookshelfPopup, bookshelf: nil)
                .environmentObject(viewModel)
        } customize: {
            $0
                .dragToDismiss(true)
                .closeOnTap(false)
        }
        .background(Color("Background"))
        .onAppear {
            Task {
                try? await viewModel.getBookshelves()
            }
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .environmentObject(UserStateViewModel())
    }
}
