//
//  BookShelfView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/7/24.
//

import SwiftUI
import PopupView
import SwiftfulLoadingIndicators

struct BookshelfView: View {
    let bookshelf: Bookshelf
    @StateObject private var viewModel: BookshelfViewModel
    @State private var showEditBookshelf: Bool = false
    @State private var showDeleteBookshelfConfirm: Bool = false
    @State var showEditBookshelfPopup: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    init(bookshelf: Bookshelf) {
        self.bookshelf  = bookshelf
        self._viewModel = StateObject(wrappedValue: BookshelfViewModel(bookshelfId: bookshelf.id))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoadingBooks {
                VStack {
                    Spacer()
                    LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                if viewModel.books.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image("emptyShelf")
                            .resizable()
                            .frame(width: 250, height: 250)
                        
                        Text("Your shelf is empty!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                      LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                          ForEach(viewModel.books) { book in
                              BookshelfBookView(book: book)
                          }
                      }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .overlay(Color.black.opacity(showEditBookshelf ? 0.3 : 0.0))
        .blur(radius: showEditBookshelf ? 2 : 0)
        .popup(isPresented: $showEditBookshelf) {
            // your content
            EditBookSelectionPopupView(showEditBookshelfPopup: $showEditBookshelfPopup, showEditBookshelf: $showEditBookshelf, showDeleteBookshelfConfirm: $showDeleteBookshelfConfirm)
        } customize: {
            $0
                .type (.toast)
                .dragToDismiss(true)
        }
        .popup(isPresented: $showEditBookshelfPopup) {
            AddBookshelfView(showNewBookshelfPopup: $showEditBookshelfPopup, bookshelf: bookshelf)
//                .environmentObject(viewModel)
        } customize: {
            $0
                .dragToDismiss(true)
                .closeOnTap(false)
        }
        .popup(isPresented: $showDeleteBookshelfConfirm) {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 40) {
                        VStack(alignment: .leading) {
                            Text("Are you sure?")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.black)
                            Text("This action cannot be undone.")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.black.opacity(0.5))
                        }
                        VStack(alignment: .leading) {
                            Button {
                                Task {
                                    try? await viewModel.deleteBookshelf(bookshelf: bookshelf)
                                    showDeleteBookshelfConfirm = false
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            } label: {
                                HStack {
                                    Text("Delete")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 300, height: 35)
                                .font(.system(size: 14))
                                .padding(10)
                                .background(Color.appColorRed)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.clear, lineWidth: 1)
                                )
                            }
                            
                            Button {
                                showDeleteBookshelfConfirm = false
                            } label: {
                                HStack {
                                    Text("Close")
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                }
                                .frame(width: 300, height: 35)
                                .font(.system(size: 14))
                                .padding(10)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.7))
            .cornerRadius(20)
            .padding(.horizontal, 40)
        }
        .background(Color("Background"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: colorScheme == .dark ? .white  : .black, dismiss: self.dismiss))
        .navigationTitle(bookshelf.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditBookshelf.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary.opacity(0.7))
                        .rotationEffect(.degrees(90))
                }
            }
        }
    }
}

//#Preview {
//    BookShelfView()
//}
