//
//  BookActionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/5/23.
//

import SwiftUI
import Combine
import PopupView

struct BookshelfButton: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    let bookshelfAddedId: String
    
    @ObservedObject var viewModel: BookViewModelNew
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .bold()
                .foregroundStyle(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(viewModel.bookshelvesAdded.contains(bookshelfAddedId) ? Color.appColorPurple : .clear)
                .cornerRadius(10)
        } else {
            content
                .bold()
                .foregroundStyle(viewModel.bookshelvesAdded.contains(bookshelfAddedId) ? .white : .black)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(viewModel.bookshelvesAdded.contains(bookshelfAddedId) ? Color.appColorPurple : .white)
                .cornerRadius(10)
        }
    }
}

struct BookActionView: View {
    let book: Book
    
    @ObservedObject var bookVM: BookViewModelNew
    
    @Binding var showBookActionSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            titleText
            ScrollView {
                bookshelves
            }
            HStack {
                Spacer()
                saveButton
                Spacer()
            }
        }
        .padding(5)
        .task {
            await bookVM.fetchBookShelves()
        }
    }
    
    private var titleText: some View {
        Text("Add to bookshelf")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .padding()
    }
    
    private var saveButton: some View {
        Button {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            Task {
                await viewModel.saveToBookshelves(bookId: book.bookId)
            }
            showBookActionSheet = false
        } label: {
            Text("Save")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 300, height: 60)
                .background(Color.appColorOrange)
                .cornerRadius(10)
        }
    }
    
    private var bookshelves: some View {
        ForEach(0..<bookVM.userBookshelves.count, id: \.self) { index in
            HStack {
                Spacer()
                Button {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    if bookVM.bookshelvesAdded.contains(bookVM.userBookshelves[index].id) {
                        if let foundIndex = bookVM.bookshelvesAdded.firstIndex(of: bookVM.userBookshelves[index].id) {
                            bookVM.bookshelvesAdded.remove(at: foundIndex)
                        }
                    } else {
                        bookVM.bookshelvesAdded.append(bookVM.userBookshelves[index].id)
                    }
                } label: {
                    HStack {
                        if bookVM.userBookshelves[index].imageUrl == "" {
                            NoPhotoBookshelfView(width: 20, height: 20)
                                .shadow(radius: 10)
                        } else {
                            if let url = URL(string: bookVM.userBookshelves[index].imageUrl) {
                                AsyncCachedImage(url: url) { image in
                                    image
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .scaledToFit()
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        Text("\(bookVM.userBookshelves[index].name)")
                            .offset(x: 10)
                            .bold()
                        
                        Spacer()
                        if bookVM.bookshelvesAdded.contains(bookVM.userBookshelves[index].id) {
                            Image(systemName: "checkmark")
                                .bold()
                                .offset(x: -20)
                        }
                    }
                    .modifier(
                        BookshelfButton(
                            bookshelfAddedId: bookVM.userBookshelves[index].id,
                            viewModel: bookVM
                        )
                    )
                }
                Spacer()
            }
        }
    }
}
