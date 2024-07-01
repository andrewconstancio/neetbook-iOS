//
//  BookCommentSectionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import SwiftUI
import SwiftfulLoadingIndicators
import Combine


struct BookCommentSectionView: View {
    @ObservedObject var viewModel: BookViewModel
    let book: Book
    @State private var height: CGFloat = 30
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.isLoadingComments {
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
                    if(viewModel.bookComments.count > 0) {
                        ForEach(0..<viewModel.bookComments.count, id: \.self) { index in
                            CommentView(bookViewModel: viewModel, bookId: book.bookId, currentUserId: viewModel.currentUserId, comment: viewModel.bookComments[index])
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
        .navigationBarBackButtonHidden(true)
        .padding(10)
        .task {
            try? await viewModel.getAllBookComments(bookId: book.bookId)
        }
    }
}

//struct BookCommentSectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookCommentSectionView(viewModel: BookViewModel(), bookId: "asdfasdf")
//    }
//}
