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
    
    @StateObject var viewModel: BookViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showBookActionSheet = false
    
    @State private var showFullDescription: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    @Namespace var animation
    
    @State var tabBarOffset: CGFloat = 0
    
    @State var titleOffset: CGFloat = 0
    
    @State var currentTab = "Info"
    
    @State var offset: CGFloat = 0
    
    @State private var activityHeight: Double = 0.0
    
    @State private var height: CGFloat = 30
    
    @State private var keyboardHeight: CGFloat = 0
    
    init(book: Book) {
        self.book = book
        self._viewModel = StateObject(wrappedValue: BookViewModel(bookId: book.bookId))
    }
    
    var body: some View {
        FittedScrollView {
            VStack(spacing: 10) {
                VStack {
                    if let coverPhoto = book.coverPhoto {
                        Image(uiImage: coverPhoto)
                            .resizable()
                            .frame(width: 90, height: 140)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .padding(.top, 100)
                            .padding(.bottom, 20)
                    }
                    
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
                        
                        if currentTab == "Info" {
                            BookSingleInfoView(name: "Title ", info: book.title)
                            BookSingleInfoView(name: "Author ", info: "\(book.author)")
                            BookSingleInfoView(name: "Publisher ", info: "\(book.publisher)")
                            BookSingleInfoView(name: "Year ", info: "\(book.publishedYear)")
                            if book.description != "" {
                                description
                            }
                        } else {
                            BookCommentSectionView(viewModel: viewModel, book: book)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color("Background"))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                }
                .background(
                    Image(uiImage: book.coverPhoto!)
                        .resizable()
                        .blur(radius: 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
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
            if currentTab == "Comments" {
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
                        Task {
                            try? await viewModel.addUserBookComment(bookId: book.bookId)
                            hideKeyboard()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color.appColorPurple)
                            .frame(width: 10, height: 10)
                            .padding(5)
                    }
                }
                .padding(.top, 5)
                .padding(4)
            }
        }
        .background(Color("Background"))
        .ignoresSafeArea()
//        FittedScrollView {
//                VStack {
//                    VStack {
//                        if let coverPhoto = book.coverPhoto {
//                            Image(uiImage: coverPhoto)
//                                .resizable()
//                                .frame(width: 125, height: 200)
//                                .cornerRadius(10)
//                                .shadow(radius: 10)
//                                .padding(.bottom, 20)
//                        }
//                    }
//                    .padding(.top, 70)
//                    
//                    VStack(alignment: .leading) {
//                        BookSingleInfoView(name: "Title ", info: book.title)
//                        BookSingleInfoView(name: "Author ", info: "\(book.author)")
//                        BookSingleInfoView(name: "Publisher ", info: "\(book.publisher)")
//                        BookSingleInfoView(name: "Year ", info: "\(book.publishedYear)")
//                        if book.description != "" {
//                            description
//                        }
//                        Spacer()
//                        Spacer()
//                        HStack {
//                            if !viewModel.bookshelvesAdded.isEmpty {
//                                savedToBookshelfButton
//                            } else {
//                                addToBookshelfButton
//                            }
//                            
//                            showCommentSectionButton
// 
////                            if viewModel.savedToFavorites {
////                                savedToFavoritesButton
////                            } else {
////                                saveToFavoritesButton
////                            }
//                        }
////                        showCommentSectionButton
//                        Spacer()
//                    }
//                    .padding(.top, 20)
//                    .padding(.horizontal, 2)
//                    .frame(maxWidth: .infinity)
//                    .edgesIgnoringSafeArea(.all)
//                    .background(Color("Background"))
////                    .cornerRadius(30, corners: [.topLeft, .topRight])
//                }
//                .background(
//                    Image(uiImage: book.coverPhoto!)
//                        .resizable()
//                        .blur(radius: 20)
//                )
//        }
//        .onTapGesture {
//            hideKeyboard()
//        }
//        .overlay(Color.black.opacity(showBookActionSheet ? 0.3 : 0.0))
//        .blur(radius: showBookActionSheet ? 2 : 0)
//        .scrollIndicators(.hidden)
//        .ignoresSafeArea()
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: NavBackButtonView(color: .white, dismiss: self.dismiss))
//        .toolbarBackground(.hidden, for: .navigationBar)
//        .sheet(isPresented: $showBookActionSheet) {
//            BookActionView(
//                viewModel: viewModel,
//                showBookActionSheet: $showBookActionSheet,
//                actionSelected: viewModel.userActions,
//                book: book
//            )
//            .onDisappear {
//                Task {
//                    try await viewModel.getBookshelvesAddedTo(bookId: book.bookId)
//                }
//            }
//        }
//        .popup(isPresented: $showBookActionSheet) {
//            BookActionView(
//                viewModel: viewModel,
//                showBookActionSheet: $showBookActionSheet,
//                actionSelected: viewModel.userActions,
//                book: book
//            )
//            .frame(height: 450)
//            .frame(maxWidth: .infinity)
//            .background(Color("Background"))
//            .cornerRadius(30, corners: [.topLeft, .topRight])
//        } customize: {
//            $0
//                .isOpaque(true)
//                .type(.toast)
//                .dragToDismiss(true)
//                .closeOnTap(false)
//        }
//        .sheet(isPresented: $viewModel.showCommentSection) {
//            BookCommentSectionView(viewModel: viewModel, book: book)
//        }
    }
    
    func getTitleTextOffset()->CGFloat{
        
        // some amount of progress for slide effect..
        let progress = 20 / titleOffset
        
        let offset = 60 * (progress > 0 && progress <= 1 ? progress : 1)
        
        return offset
    }
    
    // Profile Shrinking Effect...
    func getOffset()->CGFloat{
        
        let progress = (-offset / 80) * 20
        
        return progress <= 20 ? progress : 20
    }
    
    func getScale()->CGFloat{
        
        let progress = -offset / 80
        
        let scale = 1.8 - (progress < 1.0 ? progress : 1)
        
        // since were scaling the view to 0.8...
        // 1.8 - 1 = 0.8....
        
        return scale < 1 ? scale : 1
    }
    
    func blurViewOpacity()->Double{
    
        
        let progress = -(offset + 80) / 150
        
        return Double(-offset > 80 ? progress : 0)
    }
}

extension BookView {
    private var bookTitle: some View {
        Text(book.title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
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
            .foregroundColor(.primary.opacity(0.7))
            .bold()
    }
    
    private var description: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Description")
                    .font(.system(size: 14))
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
                Image(systemName: showFullDescription ? "chevron.up.circle" : "chevron.down.circle")
                    .frame(width: 15, height: 15)
                    .padding(.vertical, 4)
                    .foregroundColor(Color.primary.opacity(0.7))
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
    
    private var showCommentSectionButton: some View {
        NavigationLink {
            BookCommentSectionView(viewModel: viewModel, book: book)
        } label: {
            HStack {
                Image(systemName: "square.and.pencil")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Add a comment")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(height: 35)
            .frame(width: UIScreen.main.bounds.width / 2 - 40)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(colorScheme == .dark ? .indigo : .black)
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

