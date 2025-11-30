//
//  PostView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/18/24.
//

import SwiftUI

struct PostView: View {
    /// The post from the users feed.
    let post: PostFeedInstance
    
    /// The auth view model.
    @EnvironmentObject var authVM: AuthViewModelNew
    
    /// The color scheme environment.
    @Environment(\.colorScheme) var colorScheme
    
    /// The dismiss view environment.
    @Environment(\.dismiss) private var dismiss
    
    /// The post view model.
    @ObservedObject var viewModel: PostViewModel
    
    /// The height of the keyboard for a new comment.
    @State private var commentKeyboardHeight: CGFloat = 0

    var body: some View {
        VStack {
            ScrollView {
                FeedInstance(post: post)
                postComments
            }
            .scrollIndicators(.hidden)
            Spacer()
            addComment
        }
        .background(Color("Background"))
        .task {
            await viewModel.fetchPostComments(documentID: post.documentID)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle(post.title)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .primary, dismiss: self.dismiss))
    }
    
    
    /// A view that shows users comments on a post.
    @ViewBuilder
    private var postComments: some View {
        if viewModel.postComments.count > 0 {
            HStack {
                Text("Comments")
                    .bold()
                Spacer()
            }
            .padding()
            
            ForEach(viewModel.postComments) { comment in
                if let user = authVM.authState.currentUser {
                    PostCommentView(comment: comment, currentUserId: user.userId)
                        .environmentObject(viewModel)
                }
            }
        }
    }
    
    /// The area which includes a textfield to add a comment to a post.
    private var addComment: some View {
        HStack {
            if let _ = authVM.authState.currentUser, let profilePhoto = authVM.authState.currentUser?.profilePhoto {
                Image(uiImage: profilePhoto)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .shadow(radius: 10)
                    .cornerRadius(10)
                    .clipShape(Circle())
            }
        
            ResizableTF(
                text: $viewModel.newComment,
                height: $commentKeyboardHeight,
                placeholderText: "Add comment..."
            )
            .frame(height: commentKeyboardHeight)
            .padding(.horizontal)
            .background(.white)
            .cornerRadius(15)
        
            Button {
                if viewModel.commentValid {
                    Task {
                        await viewModel.insertComment(postUserID: post.user.userId, documentId: post.documentID)
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
        .padding()
    }
}

//#Preview {
//    PostView(post: PostFeedInstance(title: "Left a note", content: "This is one", documentID: "ULd0biI0Hb1oSZ85BhOW", user: DeveloperPreview.instance.user, profilePicture: UIImage(named: "onepiece")!, book: DeveloperPreview.instance.book, dateEvent: Date()))
//        .environmentObject(UserStateViewModel())
//}

