//
//  BookCommentSectionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import SwiftUI

struct BookCommentSectionView: View {
    @ObservedObject var viewModel: BookViewModel
    let bookId: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comments")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
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
                ForEach(viewModel.bookComments) { comment in
                    HStack {
                        AsyncImage(url: URL(string: comment.photoURL)) { image in
                            image
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .alignmentGuide(VerticalAlignment.center) {   // << here !!
                                      $0[VerticalAlignment.top]
                                  }

                        } placeholder: {
                            ProgressView()
                        }
                        
                        VStack(alignment: .leading) {
                            Text(comment.displayName)
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))
                            
                            Text(comment.comment ?? "")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .alignmentGuide(VerticalAlignment.center) {   // << here !!
                          $0[VerticalAlignment.top]
                      }
                    .padding(.top, 20)
                }
            }
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
