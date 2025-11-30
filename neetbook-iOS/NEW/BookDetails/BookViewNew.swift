import SwiftUI
import SwiftfulLoadingIndicators
import PopupView
import FirebaseAuth

struct BookViewNew: View {
    /// The book fetched that is passed in to view details.
    let book: Book
    
    /// The environment auth view model.
    @EnvironmentObject var authVM: AuthViewModelNew
    
    /// The environment color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// The environment dismiss view.
    @Environment(\.dismiss) private var dismiss
    
    /// The books view model.
    @StateObject var bookVM = BookViewModelNew()
    
    /// The current tab selected for the book details.
    @State var currentTab: HorizontalTab = .info
    
    /// Flag to show the full books description or not.
    @State private var showFullDescription = false
    
    /// The name space of the tab animation.
    @Namespace var tabAnimation
    
    /// The height of the keyboard for a new comment.
    @State var commentKeyboardHeight: CGFloat = 30
    
    /// Flag to show or hide the book mark sheet.
    @State var showBookMarkSheet = false
    
    @State var showBookActionSheet = false
    
    var body: some View {
        FittedScrollView {
            VStack {
                header
                detailTabs
                bookInformation
            }
        }
        .task {
            await bookVM.fetchComments(id: book.bookId)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if currentTab == .info {
                HStack {
                    markBooksButton
                    
                    if bookVM.bookshelvesAdded.isEmpty {
                        addToBookshelfButton
                    } else {
                        savedToBookshelfButton
                    }
                }
                .padding(.horizontal)
            }
            
            if currentTab == .comments {
                addComment
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: NavBackButtonView(
                color: .primary,
                dismiss: self.dismiss
            )
        )
        .blur(radius: showBookMarkSheet ? 2 : 0)
        .popup(isPresented: $showBookMarkSheet) {
            MarkBookView(bookVM: bookVM, showBookMarkSheet: $showBookMarkSheet)
        } customize: {
            $0
                .dragToDismiss(true)
                .closeOnTap(false)
        }
        .sheet(isPresented: $showBookActionSheet) {
            BookActionView(
                book: book,
                bookVM: bookVM,
                showBookActionSheet: $showBookActionSheet
            )
//            .onDisappear {
//                Task {
//                    try await viewModel.getBookshelvesAddedTo(bookId: book.bookId)
//                }
//            }
        }
    }
    
    /// The books cover photo.
    @ViewBuilder
    private var header: some View {
        VStack {
            if let url = URL(string: book.coverURL) {
                AsyncCachedImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 140, height: 220)
                        .shadow(radius: 10)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height / 3)
        .frame(maxWidth: .infinity)
        .background(
            bookBackgroundImage
        )
    }
    
    /// The detail horizontal tabs (e.g. Info or Comments).
    private var detailTabs: some View {
        // Horizontal tabs
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0){
                // Info tab.
                TabButton(
                    title: HorizontalTab.info.title,
                    tab: HorizontalTab.info,
                    animation: tabAnimation,
                    currentTab: $currentTab
                )
                .frame(width: UIScreen.main.bounds.width / 2)
                
                // Comments tab
                TabButton(
                    title: HorizontalTab.comments.title,
                    tab: HorizontalTab.comments,
                    animation: tabAnimation,
                    currentTab: $currentTab
                )
                .frame(width: UIScreen.main.bounds.width / 2)
            }
        }
        .padding(.top, 30)
        .background(Color("Background"))
        .offset(y: -6)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
    
    /// Builds a view to show the books information.
    /// - Parameters:
    ///   - name: The name of the information to display.
    ///   - info: The information to display.
    /// - Returns: The view with the information.
    func buildBookInfoSection(name: String, info: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(name)
                .font(.system(size: 16))
                .bold()
            Text(info)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    /// The books main information.
    private var bookInformation: some View {
        // Showing the books information like the title, author,
        // publisher, year and description.
        VStack(alignment: .leading) {
            if currentTab == .info {
                // Title.
                buildBookInfoSection(
                    name: "Title ",
                    info: book.title
                )
                
                // Author.
                buildBookInfoSection(
                    name: "Author ",
                    info: "\(book.author)"
                )
                
                // Description.
                if book.description != "" {
                    bookDescription
                }
                
                // Publisher.
                buildBookInfoSection(
                    name: "Publisher ",
                    info: "\(book.publisher)"
                )
                
                // Year.
                buildBookInfoSection(
                    name: "Year ",
                    info: "\(book.publishedYear)"
                )
            } else {
                BookCommentSectionView(
                    book: book,
                    bookVM: bookVM
                )
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        .offset(y: -14)
    }
    
    /// The books description where you can expand or collasp the information.
    var bookDescription: some View {
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
    
    /// The blured background image that is the books cover.
    private var bookBackgroundImage: some View {
        VStack {
            if let url = URL(string: book.coverURL) {
                AsyncCachedImage(url: url) { image in
                    image
                        .resizable()
                        .blur(radius: 25)
                        .scaleEffect(2.0)
                } placeholder: {
                    EmptyView()
                }
            }
        }
    }
    
    private var addComment: some View {
        HStack {
            if let photoURL = authVM.authState.currentUser?.photoUrl,
               let url = URL(string: photoURL) {
                AsyncCachedImage(url: url) { image in
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
            
            ResizableTF (
                text: $bookVM.newCommentText,
                height: $commentKeyboardHeight,
                placeholderText: "Add comment..."
            )
            .frame(height: commentKeyboardHeight)
            .padding(.horizontal)
            .background(.white)
            .cornerRadius(15)
            
            Button {
                if bookVM.commentValid {
                    Task {
                        await bookVM.insertComment(bookId: book.bookId)
                        hideKeyboard()
                    }
                }
            } label: {
                Text("Send")
                    .font(.system(size: 14))
                    .bold()
                    .foregroundStyle(bookVM.commentValid ? colorScheme == .dark ? .white : .black : .secondary)
                    .padding(.horizontal, 3)
            }
        }
        .padding(.horizontal, 8)
        .padding(5)
        .background(Color("Background"))
    }
    
    private var markBooksButton: some View {
        Button {
            showBookMarkSheet = true
        } label: {
            HStack {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                
                Text(bookVM.markSelected == "" ? "Mark Book" : bookVM.markSelected.capitalizeFirstLetter())
                    .fontWeight(.bold)
            }
            .frame(height: 35)
            .frame(width: UIScreen.main.bounds.width / 2 - 40)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(bookVM.markSelected == "" ? .orange : .blue)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
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
}

// TODO: Take this out

struct MarkBookView: View {
    
    /// The environment color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// The book view model.
    @ObservedObject var bookVM: BookViewModelNew
    
    /// Flag to show or hide the book mark pop up.
    @Binding var showBookMarkSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            createSelectableButton(title: "Reading", type: "reading")
            createSelectableButton(title: "Want To Read", type: "want to read")
            createSelectableButton(title: "Finished", type: "finished")
            saveButton
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.7))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    private var saveButton: some View {
        Button {
            let impactMed = UIImpactFeedbackGenerator(style: .soft)
            impactMed.impactOccurred()
//                Task {
//                    await viewModel.saveRemoveToMarkedBooks()
//                }
            showBookMarkSheet = false
        } label: {
            HStack {
                Spacer()
                Text("Save")
                    .bold()
                Spacer()
            }
            .bold()
            .frame(height: 30)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appColorOrange)
            .cornerRadius(10)
        }
    }
    
    private func createSelectableButton(title: String, type: String) -> some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .soft)
            impactMed.impactOccurred()
            if bookVM.markSelected == "" || bookVM.markSelected != type {
                bookVM.markSelected = type
            } else {
                bookVM.markSelected = ""
            }
        }) {
            HStack {
                Text(title)
                    .offset(x: 10)
                    .bold()
                Spacer()
            }
            .bold()
            .frame(height: 30)
            .foregroundStyle(bookVM.markSelected == type ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(bookVM.markSelected == type ? .green : .white)
            .cornerRadius(10)
        }
    }
}

struct BookViewNew_Previews: PreviewProvider {
    static var previews: some View {
        BookViewNew(book: dev.book)
    }
}
