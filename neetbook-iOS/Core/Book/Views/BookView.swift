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
    
    let book: Book
    
    @StateObject var viewModel: BookViewModel = BookViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showBookActionSheet = false
    
    @State private var showBookMarkSheet: Bool = false
    
    @State private var showFullDescription: Bool = false

    @State var tabBarOffset: CGFloat = 0
    
    @State var titleOffset: CGFloat = 0
    
    @State var currentTab = "Info"
    
    @State var offset: CGFloat = 0
    
    @State private var activityHeight: Double = 0.0
    
    @State private var height: CGFloat = 30
    
    @State private var keyboardHeight: CGFloat = 0
    
    @Namespace var animation
    
//    init(book: Book) {
//        self.book = book
//        self._viewModel = StateObject(wrappedValue: BookViewModel(bookId: book.bookId))
//    }
    
    var body: some View {
        VStack {
            FittedScrollView {
                VStack(spacing: 10) {
                    VStack {
                        // cover photo
                        if let coverPhoto = book.coverPhoto {
                            Image(uiImage: coverPhoto)
                                .resizable()
                                .frame(width: 90, height: 140)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                                .padding(.top, 100)
                                .padding(.bottom, 20)
                        }
                        
                        // horizontal tabs
                        VStack(alignment: .leading) {
                            VStack(spacing: 0){
                                ScrollView(.horizontal, showsIndicators: false, content: {
                                    HStack(spacing: 0){
                                        TabButton(title: "Info", currentTab: $currentTab, animation: animation)
                                            .frame(width: UIScreen.main.bounds.width / 2)
                                        
                                        TabButton(title: "Comments", currentTab: $currentTab, animation: animation)
                                            .frame(width: UIScreen.main.bounds.width / 2)
                                    }
                                })
                                .padding(.top, 30)
                                Divider()
                            }
                            
                            // content
                            if currentTab == "Info" {
                                BookSingleInfoView(name: "Title ", info: book.title)
                                BookSingleInfoView(name: "Author ", info: "\(book.author)")
                                if book.description != "" {
                                    description
                                }
                                BookSingleInfoView(name: "Publisher ", info: "\(book.publisher)")
                                BookSingleInfoView(name: "Year ", info: "\(book.publishedYear)")
                            } else {
                                BookCommentSectionView(viewModel: viewModel, book: book)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 200)
                        .padding(.horizontal, 2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        .background(Color("Background"))
                        .cornerRadius(10, corners: [.topLeft, .topRight])
                    }
                }
                .background(
                    VStack {
                        Image(uiImage: book.coverPhoto!)
                            .resizable()
                            .blur(radius: 25)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height / 2)
                        Spacer()
                    }
                )
            }
            Spacer()
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
        .sheet(isPresented: $showBookActionSheet) {
            BookActionView(
                viewModel: viewModel,
                showBookActionSheet: $showBookActionSheet,
                actionSelected: viewModel.userActions,
                book: book
            )
            .onDisappear {
                Task {
                    try await viewModel.getBookshelvesAddedTo(bookId: book.bookId)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if currentTab == "Info" {
                HStack {
                    markBookButton
                    if viewModel.bookshelvesAdded.isEmpty {
                        addToBookshelfButton
                    } else {
                        savedToBookshelfButton
                    }
                }
                .padding(.horizontal, 10)
            }
            
            if currentTab == "Comments" {
                addComment
            }
        }
        .task {
            try? await viewModel.initBookDetails(bookId: book.bookId)
        }
        .overlay(Color.black.opacity(showBookMarkSheet ? 0.3 : 0.0))
        .blur(radius: showBookMarkSheet ? 2 : 0)
        .popup(isPresented: $showBookMarkSheet) {
            MarkBookView(viewModel: viewModel, showBookMarkSheet: $showBookMarkSheet)
        } customize: {
            $0
                .dragToDismiss(true)
                .closeOnTap(false)
        }
        .background(Color("Background"))
    }
    
}

extension BookView {
    
    private var description: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Description")
                    .font(.system(size: 16))
                    .bold()
                
                Text(book.description.htmlStripped)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(showFullDescription ? nil : 3)
            }
            Button {
                withAnimation(.easeOut) {
                    showFullDescription.toggle()
                }
            } label: {
                HStack {
                    Text(showFullDescription ? "Read Less" : "Read More")
                        .font(.system(size: 14))
                        .bold()
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .padding(.top, 1)
                    Spacer()
                }
            }
        }
        .padding()
    }
    
    private var addToBookshelfButton: some View {
        Button {
            showBookActionSheet = true
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                    .fontWeight(.bold)
                
                Text("Add to bookshelf")
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
//            .frame(width: UIScreen.main.bounds.width / 2 - 40)
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
    
    private var addComment: some View {
        HStack {
            if let photoURL = viewModel.currentUser?.photoUrl {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .shadow(radius: 10)
                        .cornerRadius(10)
                        .clipShape(Circle())
                    
                } placeholder: {
                    ProgressView()
                }
            }
            ResizableTF(text: $viewModel.userNewComment, height: $height)
                .frame(height: height)
                .padding(.horizontal)
                .background(.white)
                .cornerRadius(15)
            
            Button {
                if viewModel.commentValid {
                    Task {
                        try? await viewModel.addUserBookComment(bookId: book.bookId)
                        hideKeyboard()
                    }
                }
            } label: {
                Text("Send")
                    .font(.system(size: 14))
                    .bold()
                    .foregroundStyle(viewModel.commentValid ? colorScheme == .dark ? .white : .black : .secondary)
                    .padding(.horizontal, 3)
            }
        }
        .padding(.horizontal, 8)
        .padding(5)
        .background(Color("Background"))
    }
    
    private var markBookButton: some View {
        Button {
            showBookMarkSheet = true
        } label: {
            HStack {
                Image(systemName: "check")
                    .fontWeight(.bold)
                
                Text(viewModel.markSelected == "" ? "Mark Book" : viewModel.markSelected.capitalizeFirstLetter())
                    .fontWeight(.bold)

            }
            .frame(height: 35)
            .frame(width: UIScreen.main.bounds.width / 2 - 40)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(viewModel.markSelected == "" ? .orange : .blue)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
    }
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(book: dev.book)
    }
}

