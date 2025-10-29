import SwiftUI
import SwiftfulLoadingIndicators
import PopupView
import FirebaseAuth

struct BookViewNew: View {
    let book: Book
    
    @StateObject var bookVM = BookViewModelNew()
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var currentTab = "Info"
    
    @State private var showFullDescription = false
    
    @Namespace var animation
    
    var body: some View {
        GeometryReader { geometry in
            FittedScrollView {
                VStack {
                    // Book cover photo
                    if let url = URL(string: book.coverURL) {
                        AsyncCachedImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 90, height: 140)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                                .padding(.top, 100)
                                .padding(.bottom, 20)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    // Horizontal tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0){
                            TabButton(
                                title: "Info",
                                currentTab: $currentTab,
                                animation: animation
                            )
                            .frame(width: geometry.size.width / 2)
                            
                            TabButton(
                                title: "Comments",
                                currentTab: $currentTab,
                                animation: animation
                            )
                            .frame(width: geometry.size.width / 2)
                        }
                    }
                    .padding(.top, 40)
                    .background(Color("Background"))
                    
                    // Showing the books information like the title, author,
                    // publisher, year and description.
                    VStack(alignment: .leading) {
                        if currentTab == "Info" {
                            
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
                        }
                    }
                    .padding(.bottom, 200)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("Background"))
                }
            }
            .background(
                VStack {
                    if let url = URL(string: book.coverURL) {
                        AsyncCachedImage(url: url) { image in
                            image
                                .resizable()
                                .blur(radius: 25)
                                .frame(maxWidth: .infinity)
                                .frame(width: geometry.size.width / 2)
                        } placeholder: {
                            EmptyView()
                        }
                    }
                }
            )
        }
    }
    
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
}

@MainActor
class BookViewModelNew: ObservableObject {
    
    @Published private(set) var comments: [BookComment] = []
    
    @Published private(set) var isLoadingComments = false
    
    func fetchComments(id: String) async {
        do {
            self.isLoadingComments = true
            self.comments = try await BookUserCommentManager.shared.getAllBookComments(bookId: id)
            self.isLoadingComments = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteComment(id: String, documentId: String) async {
        do {
            try await BookUserCommentManager.shared.deleteBookComment(bookId: id, documentId: documentId)
            self.comments =  self.comments.filter { $0.documentId != documentId}
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func reportComment(id: String, documentId: String, comment: String) async {
        do {
            try await BookUserCommentManager
                .shared
                .reportComment(bookId: id, commentDocID: documentId, comment: comment)
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct BookCommentSectionView: View {
    let book: Book
    
    @ObservedObject var bookVM: BookViewModelNew
    
    @State var height: CGFloat = 30
    
    @State var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if bookVM.isLoadingComments {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                VStack(alignment: .leading) {
                    if(bookVM.comments.count > 0) {
                        ForEach(bookVM.comments) { comment in
                            CommentViewNew(
                                bookId: book.bookId,
                                comment: comment,
                                currentUserId: Auth.auth().currentUser?.uid ?? "",
                                bookVM: bookVM
                            )
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("No Comments...yet!")
                                .bold()
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .padding(10)
        .task {
            await bookVM.fetchComments(id: book.bookId)
        }
    }
}

struct CommentViewNew: View {
    let bookId: String
    let comment: BookComment
    let currentUserId: String
    
    @State var showSheetDelete = false
    @ObservedObject var bookVM: BookViewModelNew
    
    @State private var showSheetReport = false
    
    var body: some View {
        HStack(alignment: .top) {
            Image(uiImage: comment.profilePicture)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Text(comment.displayName)
                        .font(.headline)
                        .foregroundColor(.primary.opacity(0.7))
                    
                    Text("\(dateFormatter.string(from: comment.dateCreated))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Text(comment.comment ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
 
            Button {
                if currentUserId == comment.userId {
                    showSheetDelete = true
                } else {
                    showSheetReport = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.primary.opacity(0.7))
                    .rotationEffect(.degrees(90))
            }
            .padding(.top, 8)
        }
        .font(.system(size: 14))
        .popup(isPresented: $showSheetDelete) {
            VStack(spacing: 20) {
                if self.currentUserId == comment.userId {
                    deleteCommentButton
                }
                closeButtonDelete
            }
            .foregroundColor(.white)
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(30, corners: [.topLeft, .topRight])
        } customize: {
            $0
                .isOpaque(true)
                .type(.toast)
                .dragToDismiss(true)
        }
        .popup(isPresented: $showSheetReport) {
            VStack(spacing: 20) {
                reportCommentButton
                closeButtonReport
            }
            .foregroundColor(.white)
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(30, corners: [.topLeft, .topRight])
        } customize: {
            $0
                .isOpaque(true)
                .type(.toast)
                .dragToDismiss(true)
        }
        .padding(.top, 20)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    private var deleteCommentButton: some View {
        Button {
            Task {
                await bookVM.deleteComment(
                    id: bookId,
                    documentId: comment.documentId
                )
                showSheetDelete = false
            }
        } label: {
            HStack {
                Text("Delete")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 300, height: 55)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.appColorRed)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
    }
    
    private var reportCommentButton: some View {
        Button {
            Task {
                await bookVM.reportComment(
                    id: bookId,
                    documentId: comment.documentId,
                    comment: comment.comment ?? ""
                )
                showSheetReport = false
            }
        } label: {
            HStack {
                Text("Report")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 300, height: 55)
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
    
    private var closeButtonReport: some View {
        Button {
            showSheetReport = false
        } label: {
            HStack {
                Text("Close")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .frame(width: 300, height: 55)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.white)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
    }
    
    private var closeButtonDelete: some View {
        Button {
            showSheetDelete = false
        } label: {
            HStack {
                Text("Close")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .frame(width: 300, height: 55)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.white)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
    }
}


// MARK: Tab Button

struct TabButton: View {
    
    var title: String
    @Binding var currentTab: String
    var animation: Namespace.ID
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View{
        Button(action: {
            withAnimation{
                currentTab = title
            }
        }, label: {
            LazyVStack(spacing: 12) {
                if colorScheme == .dark {
                    Text(title)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(currentTab == title ? Color.white : Color.white.opacity(0.5))
                        .padding(.horizontal)
                } else {
                    Text(title)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(currentTab == title ? Color.appColorPurple : .gray)
                        .padding(.horizontal)
                }
                
                if currentTab == title {
                    Capsule()
                        .fill(Color.appColorPurple)
                        .frame(height: 1.2)
                        .matchedGeometryEffect(id: "TAB", in: animation)
                } else{
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 1.2)
                }
            }
        })
    }
}

struct BookViewNew_Previews: PreviewProvider {
    static var previews: some View {
        BookViewNew(book: dev.book)
    }
}
