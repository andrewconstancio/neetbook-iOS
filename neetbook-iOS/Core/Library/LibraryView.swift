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
import Shimmer

enum BookListType: String {
    case reading = "reading", wantToRead = "want to read", finished = "finished"
}

struct LibraryView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @StateObject private var viewModel = LibraryViewModel()
    
    @State var showNewBookshelfPopup: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Library")
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
            
            // custom bookshelves view
            HStack {
                Spacer()
                NavigationLink {
                    MarkedBookView(markType: .reading)
                } label: {
                    VStack(spacing: 5) {
                        Image("readingBook")
                            .resizable()
                            .frame(width: 60, height: 60)
                        HStack {
                            Text("Reading")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Text("(\(viewModel.readingCount))")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14))
                                .offset(x: -3)
                        }
                    }
                }
                Spacer()
                NavigationLink {
                    MarkedBookView(markType: .wantToRead)
                } label: {
                    VStack(spacing: 5) {
                        Image("wantToRead")
                            .resizable()
                            .frame(width: 60, height: 60)
                        HStack {
                            Text("Want To Read")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Text("(\(viewModel.wantToReadCount))")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14))
                                .offset(x: -3)
                        }
                    }
                }
                Spacer()
                NavigationLink {
                    MarkedBookView(markType: .finished)
                } label: {
                    VStack(spacing: 5) {
                        Image("finishedBook")
                            .resizable()
                            .frame(width: 60, height: 60)
                        HStack {
                            Text("Finished")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Text("(\(viewModel.finishedCount))")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14))
                                .offset(x: -3)
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            HStack {
                Text("Bookshelves")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .bold()
                Spacer()
            }
            .padding()
            
            if viewModel.shelves.count == 0 {
                VStack {
                    Text("Create your first bookshelf!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .bold()
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.shelves)  { shelf in
                        HStack {
                            if shelf.imageUrl == "" {
                                NoPhotoBookshelfView(width: 20, height: 20)
                                    .shadow(radius: 10)
                            } else {
                                AsyncImage(url: URL(string: shelf.imageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        Circle()
                                            .frame(width: 50, height: 50)
                                            .redacted(reason: .placeholder)
                                            .shimmering()
                                            .opacity(0.5)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .clipped()
                                    case .failure(let error):
                                            VStack {
                                                Image(systemName: "xmark.octagon")
                                                Text("Failed to load")
                                                if let error = error as? URLError {
                                                    Text(error.localizedDescription)
                                                }
                                            }
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.red)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }

                            NavigationLink {
                                BookshelfView(bookshelf: shelf)
                            } label: {
                                HStack {
                                    Text(shelf.name)
                                        .bold()
                                        .foregroundStyle(.primary)
                                        .offset(x: 10, y: 0)
                                    
                                    if let count = shelf.count {
                                        Text("(\(count))")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 14))
                                            .offset(x: 10)
                                    } else {
                                        Text("(0)")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 14))
                                            .offset(x: 10)
                                    }
                                    
                                    if let privateBookshelf = shelf.isPublic {
                                        if privateBookshelf == false {
                                            Image(systemName: "lock")
                                                .foregroundStyle(Color.appColorOrange.opacity(0.7))
                                                .font(.system(size: 16))
                                                .bold()
                                                .offset(x: 10)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets())
                        .padding()
                        .frame(height: 85)
                        .background(Color("Background"))
                    }
                    .onDelete { indexSet in
                        delete(indexSet: indexSet)
                    }
                    .onMove { indexSet, newOffset in
                        move(indexSet: indexSet, newOffset: newOffset)
                    }
                }
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .padding(.bottom, 30)
            }
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
                try? await viewModel.getMarkedBooksCount()
            }
        }
    }
    
    func move(indexSet: IndexSet, newOffset: Int) {

    }

    func delete(indexSet: IndexSet) {
        if let index = indexSet.first {
            let removedShelf = viewModel.shelves[index]
            Task {
                try? await viewModel.deleteBookshelf(id: removedShelf.id)
            }
            viewModel.shelves.remove(atOffsets: indexSet)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .environmentObject(UserStateViewModel())
    }
}
