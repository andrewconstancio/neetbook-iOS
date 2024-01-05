//
//  BookCommentSectionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct BookCommentSectionView: View {
    @ObservedObject var viewModel: BookViewModel
    let book: Book
//    let bookId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.isLoadingComments {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LoadingIndicator(animation: .threeBallsRotation, color: .black, speed: .fast)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                Text(book.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                TextField("", text: $viewModel.userNewComment, axis: .vertical)
                .placeholder(when: viewModel.userNewComment.isEmpty) {
                    Text("Leave a comment...")
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .padding(10)
                .padding()
                .background(.white)
                .overlay(
                   RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(0.5))
               )
                
                if !viewModel.userNewComment.isEmpty && viewModel.userNewComment.count > 3 {
                    Button {
                        Task {
                            try? await viewModel.addUserBookComment(bookId: book.bookId)
                            hideKeyboard()
                        }
                    } label: {
                        Text("Post")
                            .padding(15)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(height: 70)
                            .frame(maxWidth: .infinity)
                            .background(Color.appColorPurple)
                            .cornerRadius(30)
                    }
                }
                if(viewModel.bookComments.count > 0) {
                    ScrollView {
                        ForEach(0..<viewModel.bookComments.count, id: \.self) { index in
                            CommentView(bookViewModel: viewModel, bookId: book.bookId, currentUserId: viewModel.currentUserId, comment: viewModel.bookComments[index])
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            Spacer()
        }
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
