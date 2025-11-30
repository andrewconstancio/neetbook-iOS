//
//  BookCommentSectionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//
import SwiftUI
import SwiftfulLoadingIndicators
import FirebaseAuth

struct BookCommentSectionView: View {
    /// The book fetched that is passed in to view details.
    let book: Book
    
    /// The books view model.
    @ObservedObject var bookVM: BookViewModelNew
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            bookComments
        }
        .onTapGesture {
            hideKeyboard()
        }
        .padding(10)
    }
    
    /// Comments for the book.
    private var bookComments: some View {
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
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
    }
}
