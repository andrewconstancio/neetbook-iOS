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
    let bookId: String
    
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
                Text("Comments")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 5)
                
                TextField("", text: $viewModel.userNewComment, axis: .vertical)
                .placeholder(when: viewModel.userNewComment.isEmpty) {
                    Text("Leave a comment...")
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .padding()
                .background(.white)
                .overlay(
                   RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.5))
               )
                
                if !viewModel.userNewComment.isEmpty && viewModel.userNewComment.count > 3 {
                    Button {
                        Task {
                            try? await viewModel.addUserBookComment(bookId: bookId)
                            try? await viewModel.getAllBookComments(bookId: bookId)
                        }
                    } label: {
                        Text("Comment")
                            .padding(15)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .cornerRadius(25)
                    }
                }
                if(viewModel.bookComments.count > 0) {
                    ForEach(0..<viewModel.bookComments.count, id: \.self) { index in
                        CommentView(bookViewModel: viewModel, bookId: bookId, currentUserId: viewModel.currentUserId, comment: viewModel.bookComments[index])
                    }
                }
            }
            
            Spacer()
        }
        .task {
            try? await viewModel.getAllBookComments(bookId: bookId)
        }
    }
}

struct BookCommentSectionView_Previews: PreviewProvider {
    static var previews: some View {
        BookCommentSectionView(viewModel: BookViewModel(), bookId: "asdfasdf")
    }
}
