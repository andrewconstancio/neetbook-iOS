//
//  BookView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI

enum ReadingActions {
    case reading
    case wantToRead
    case read
    case removeAction
}

struct BookView: View {
    @StateObject var viewModel = BookViewModel()
    @State private var showBookActionSheet = false
    @State private var showFullDescription: Bool = false
    
    let book: Book
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    if let coverPhoto = book.coverPhoto {
                        Image(uiImage: coverPhoto)
                            .resizable()
                            .frame(width: 150, height: 250)
                            .shadow(radius: 10)
                    }
                    
                    VStack(alignment: .leading) {
                        bookTitle
                        
                        authorName
                        
                        description
                        
                        TagCloudView(tags: book.categories)
                    }
                    .navigationTitle(book.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if viewModel.userActions != nil && viewModel.savedActionToDB {
                        savedToBookshelfButton
                    } else {
                        addToBookshelfButton
                    }
                    Spacer()
                    Spacer()
                    //comment section
                    BookCommentSectionView(viewModel: viewModel, bookId: book.bookId)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddToFavoritesView(book: book)
                    } label: {
                        if viewModel.savedToFavorites {
                            Image(systemName: "star.fill")
                                .font(.headline)
                                .foregroundColor(.orange)
                        } else {
                            Image(systemName: "star")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .adaptiveSheet(isPresented: $showBookActionSheet, detents: [.medium()]) {
                BookActionView(
                    viewModel: viewModel,
                    showBookActionSheet: $showBookActionSheet,
                    actionSelected: viewModel.userActions,
                    book: book
                )
            }
            .onAppear {
                print(book.bookId)
                Task {
                    try await viewModel.getUserBookAction(bookId: book.bookId)
                    try await viewModel.checkIfUserAddedBookToFavoritesList(bookId: book.bookId)
                }
            }
            .onDisappear {
                print("here")
                showBookActionSheet = false
            }
        }
    }
}

extension BookView {
//    private var bookCoverImage: some View {
//        Image(uiImage: book.coverPhoto)
//            .resizable()
//            .frame(width: 150, height: 250)
//            .shadow(radius: 10)
//    }
    
    private var bookTitle: some View {
        Text(book.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
    
    private var authorName: some View {
        Text(book.author)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
    }
    
    private var description: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Description")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 5)
                
//                book.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                Text(book.description.htmlStripped)
                    .font(.system(size: 15))
                    .font(.body)
                    .lineLimit(showFullDescription ? nil : 5)
                    .foregroundColor(.primary)
            }
            
            Button {
                withAnimation(.easeOut) {
                    showFullDescription.toggle()
                }
            } label: {
                Image(systemName: showFullDescription ? "chevron.up.circle" : "chevron.down.circle")
                    .frame(width: 15, height: 15)
                    .padding(.vertical, 4)
                    .foregroundColor(Color.systemGray2)
            }
        }
    }
    
    private var savedToBookshelfButton: some View {
        Button {
            showBookActionSheet = true
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Saved to library")
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .font(.system(size: 18))
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.green, lineWidth: 2)
            )
        }

    }
    
    private var addToBookshelfButton: some View {
        Button {
            showBookActionSheet = true
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                Text("Add to library")
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .font(.system(size: 18))
            .padding()
            .foregroundColor(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.primary, lineWidth: 2)
            )
        }
        .adaptiveSheet(isPresented: $showBookActionSheet, detents: [.medium()]) {
            BookActionView(
                viewModel: viewModel,
                showBookActionSheet: $showBookActionSheet,
                actionSelected: viewModel.userActions,
                book: book
            )
        }
    }
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(
            book: Book(
                    bookId: "ydQiDQAAQBAJ",
                    title: "Dune",
                    author: "Frank Herbert",
                    coverURL: "http://books.google.com/books/content?id=ydQiDQAAQBAJ&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api",
                    description: "NOW A MAJOR MOTION PICTURE directed by Denis Villeneuve and starring Timothée Chalamet, Zendaya, Jason Momoa, Rebecca Ferguson, Oscar Isaac, Josh Brolin, Stellan Skarsgård, Dave Bautista, Stephen McKinley Henderson, Chang Chen, Charlotte Rampling, and Javier Bardem A deluxe hardcover edition of the best-selling science-fiction book of all time—part of Penguin Galaxy, a collectible series of six sci-fi/fantasy classics, featuring a series introduction by Neil Gaiman Winner of the AIGA + Design Observer 50 Books | 50 Covers competition Science fiction’s supreme masterpiece, Dune will be forever considered a triumph of the imagination. Set on the desert planet Arrakis, it is the story of the boy Paul Atreides, who will become the mysterious man known as Muad’Dib. Paul’s noble family is named stewards of Arrakis, whose sands are the only source of a powerful drug called “the spice.” After his family is brought down in a traitorous plot, Paul must go undercover to seek revenge, and to bring to fruition humankind’s most ancient and unattainable dream. A stunning blend of adventure and mysticism, environmentalism and politics, Dune won the first Nebula Award, shared the Hugo Award, and formed the basis of what is undoubtedly the grandest epic in science fiction. Penguin Galaxy Six of our greatest masterworks of science fiction and fantasy, in dazzling collector-worthy hardcover editions, and featuring a series introduction by #1 New York Times bestselling author Neil Gaiman, Penguin Galaxy represents a constellation of achievement in visionary fiction, lighting the way toward our knowledge of the universe, and of ourselves. From historical legends to mythic futures, monuments of world-building to mind-bending dystopias, these touchstones of human invention and storytelling ingenuity have transported millions of readers to distant realms, and will continue for generations to chart the frontiers of the imagination. The Once and Future King by T. H. White Stranger in a Strange Land by Robert A. Heinlein Dune by Frank Herbert 2001: A Space Odyssey by Arthur C. Clarke The Left Hand of Darkness by Ursula K. Le Guin Neuromancer by William Gibson For more than seventy years, Penguin has been the leading publisher of classic literature in the English-speaking world. With more than 1,700 titles, Penguin Classics represents a global bookshelf of the best works throughout history and across genres and disciplines. Readers trust the series to provide authoritative texts enhanced by introductions and notes by distinguished scholars and contemporary authors, as well as up-to-date translations by award-winning translators.",
                    pageCount: 706,
                    categories: ["Fiction", "Science Fiction" , "History", "Science", "Science"]
            )
        )
    }
}
