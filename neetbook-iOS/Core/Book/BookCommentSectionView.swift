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
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.showCommentSection = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                }
                .padding(.top, 10)
                
                TextField("", text: $viewModel.userNewComment, axis: .vertical)
                .placeholder(when: viewModel.userNewComment.isEmpty) {
                    Text("Leave a comment...")
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .padding(.top, 20)
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
