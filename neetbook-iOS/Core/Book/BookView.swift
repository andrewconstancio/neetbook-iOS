//
//  BookView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI
import PopupView
import SwiftfulLoadingIndicators

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
    @Environment(\.dismiss) private var dismiss
    
    let book: Book
    
    var body: some View {
        FittedScrollView {
            if viewModel.bookInfoIsLoading {
                VStack {
                    Spacer()
                    LoadingIndicator(animation: .threeBalls, color: .black, speed: .fast)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
            } else {
                VStack {
                    VStack {
                        if let coverPhoto = book.coverPhoto {
                            Image(uiImage: coverPhoto)
                                .resizable()
                                .frame(width: 125, height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                                .padding(.bottom, 20)
                        }
                    }
                    .padding(.top, 120)
                    
                    VStack() {
                        HStack {
                            bookTitle
                            bookYear
                        }
                        
                        authorName
                        description
                        Spacer()
                        Spacer()
                        HStack {
                            if viewModel.userActions != nil && viewModel.savedActionToDB {
                                savedToBookshelfButton
                            } else {
                                addToBookshelfButton
                            }
                            
                            if viewModel.savedToFavorites {
                                savedToFavoritesButton
                            } else {
                                saveToFavoritesButton
                            }
                        }
                        showCommentSectionButton
                        Spacer()
                        HStack {
                            VStack {
                                Text("\(viewModel.bookStats?.readingCount ?? 0)")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                
                                Image(systemName: "book.fill")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                            }
                            Spacer()
                            VStack {
                                Text("\(viewModel.bookStats?.wantToReadCount ?? 0)")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                            }
                            Spacer()
                            VStack {
                                Text("\(viewModel.bookStats?.readCount ?? 0)")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                
                                Image(systemName: "book.closed.fill")
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.horizontal, 60)
                        Spacer()
                        Spacer()
                    }
                    .padding()
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                }
                .background(Color.appGradientOne)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .overlay(Color.black.opacity(showBookActionSheet ? 0.3 : 0.0))
        .blur(radius: showBookActionSheet ? 2 : 0)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .white, dismiss: self.dismiss))
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            try? await viewModel.getBookMainInformation(bookId: book.bookId)
        }
        .popup(isPresented: $showBookActionSheet) {
            BookActionView(
                viewModel: viewModel,
                showBookActionSheet: $showBookActionSheet,
                actionSelected: viewModel.userActions,
                book: book
            )
            .foregroundColor(.white)
            .frame(height: 450)
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(30, corners: [.topLeft, .topRight])
        } customize: {
            $0
                .isOpaque(true)
                .type(.toast)
                .dragToDismiss(true)
                .closeOnTap(false)
        }
//        .sheet(isPresented: $viewModel.showCommentSection) {
//            BookCommentSectionView(viewModel: viewModel, book: book)
//        }
    }
}

extension BookView {
    private var bookTitle: some View {
        Text(book.title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    private var bookYear: some View {
        Text("(\(book.publishedYear))")
            .font(.system(size: 15))
            .foregroundColor(.secondary)
    }
    
    private var authorName: some View {
        Text("by \(book.author)")
            .foregroundColor(.black.opacity(0.7))
    }
    
    private var description: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Description")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.top, 5)
                
                Text(book.description.htmlStripped)
                    .font(.system(size: 15))
                    .font(.body)
                    .lineLimit(showFullDescription ? nil : 3)
                    .foregroundColor(.black)
            }
            
            Button {
                withAnimation(.easeOut) {
                    showFullDescription.toggle()
                }
            } label: {
                Image(systemName: showFullDescription ? "chevron.up.circle" : "chevron.down.circle")
                    .frame(width: 15, height: 15)
                    .padding(.vertical, 4)
                    .foregroundColor(Color.black.opacity(0.7))
            }
        }
        .cornerRadius(15)
    }
    
    private var addToBookshelfButton: some View {
        Button {
            showBookActionSheet = true
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                    .fontWeight(.bold)
                Text("Add to library")
                    .fontWeight(.bold)

            }
            .frame(height: 35)
            .frame(width: UIScreen.main.bounds.width / 2 - 40)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.appColorOrange)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )

        }
    }
    
    private var saveToFavoritesButton: some View {
        NavigationLink {
            AddToFavoritesView(book: book)
        } label: {
            HStack {
                Image(systemName: "star")
                    .fontWeight(.bold)
                Text("Add to favorites")
                    .fontWeight(.bold)

            }
            .frame(height: 35)
            .frame(width: UIScreen.main.bounds.width / 2 - 40)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.blue)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
    }
    
    private var savedToFavoritesButton: some View {
        NavigationLink {
            AddToFavoritesView(book: book)
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .fontWeight(.bold)
                Text("Saved to favorites")
                    .fontWeight(.bold)
            }
            .frame(height: 35)
            .frame(width: UIScreen.main.bounds.width / 2 - 40)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.blue)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
    }
    
    private var savedToBookshelfButton: some View {
        Button {
            showBookActionSheet = true
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .fontWeight(.bold)
                Text("Saved to library")
                    .fontWeight(.bold)
            }
            .frame(height: 35)
            .frame(width: UIScreen.main.bounds.width / 2 - 40)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(.green)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
    }
    
    private var showCommentSectionButton: some View {
        NavigationLink {
            BookCommentSectionView(viewModel: viewModel, book: book)
//            withAnimation(.easeInOut(duration: 0.3)) {
//                viewModel.showCommentSection = true
//            }
        } label: {
            HStack {
                Text("Comments")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(height: 65)
            .frame(maxWidth: .infinity)
            .background(.black)
            .cornerRadius(30)
        }
        .padding(.top, 10)
//        Button {
////            withAnimation(.easeInOut(duration: 0.3)) {
////                viewModel.showCommentSection = true
////            }
//        } label: {
//            HStack {
//                Text("Comments")
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//            }
//            .frame(height: 65)
//            .frame(maxWidth: .infinity)
//            .background(.black)
//            .cornerRadius(30)
//        }
//        .padding(.top, 10)
    }
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(
            book: Book(
                    bookId: "ydQiDQAAQBAJ",
                    title: "How to make this work in swift",
                    author: "Frank Herbert",
                    coverURL: "http://books.google.com/books/content?id=ydQiDQAAQBAJ&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api",
                    description: "NOW A MAJOR MOTION PICTURE directed by Denis Villeneuve and starring Timothée Chalamet, Zendaya, Jason Momoa, Rebecca Ferguson, Oscar Isaac, Josh Brolin, Stellan Skarsgård, Dave Bautista, Stephen McKinley Henderson, Chang Chen, Charlotte Rampling, and Javier Bardem A deluxe hardcover edition of the best-selling science-fiction book of all time—part of Penguin Galaxy, a collectible series of six sci-fi/fantasy classics, featuring a series introduction by Neil Gaiman Winner of the AIGA + Design Observer 50 Books | 50 Covers competition Science fiction’s supreme masterpiece, Dune will be forever considered a triumph of the imagination. Set on the desert planet Arrakis, it is the story of the boy Paul Atreides, who will become the mysterious man known as Muad’Dib. Paul’s noble family is named stewards of Arrakis, whose sands are the only source of a powerful drug called “the spice.” After his family is brought down in a traitorous plot, Paul must go undercover to seek revenge, and to bring to fruition humankind’s most ancient and unattainable dream. A stunning blend of adventure and mysticism, environmentalism and politics, Dune won the first Nebula Award, shared the Hugo Award, and formed the basis of what is undoubtedly the grandest epic in science fiction. Penguin Galaxy Six of our greatest masterworks of science fiction and fantasy, in dazzling collector-worthy hardcover editions, and featuring a series introduction by #1 New York Times bestselling author Neil Gaiman, Penguin Galaxy represents a constellation of achievement in visionary fiction, lighting the way toward our knowledge of the universe, and of ourselves. From historical legends to mythic futures, monuments of world-building to mind-bending dystopias, these touchstones of human invention and storytelling ingenuity have transported millions of readers to distant realms, and will continue for generations to chart the frontiers of the imagination. The Once and Future King by T. H. White Stranger in a Strange Land by Robert A. Heinlein Dune by Frank Herbert 2001: A Space Odyssey by Arthur C. Clarke The Left Hand of Darkness by Ursula K. Le Guin Neuromancer by William Gibson For more than seventy years, Penguin has been the leading publisher of classic literature in the English-speaking world. With more than 1,700 titles, Penguin Classics represents a global bookshelf of the best works throughout history and across genres and disciplines. Readers trust the series to provide authoritative texts enhanced by introductions and notes by distinguished scholars and contemporary authors, as well as up-to-date translations by award-winning translators.",
                    publishedYear: "1979"
            )
        )
    }
}
