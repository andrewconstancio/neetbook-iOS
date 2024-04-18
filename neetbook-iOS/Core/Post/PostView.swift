//
//  PostView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/18/24.
//

import SwiftUI

struct PostView: View {
    let post: PostFeedInstance
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = PostViewModel()
    
    @State private var height: CGFloat = 30
    
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack {
            ScrollView {
                PostInstanceView(post: post, linkToPost: false)
                    .environmentObject(userStateViewModel)
                if viewModel.postComments.count > 0 {
                    HStack {
                        Text("Comments")
                            .bold()
                        Spacer()
                    }
                    .padding()
                    ForEach(viewModel.postComments) { comment in
                        if let user = userStateViewModel.user {
                            PostCommentView(comment: comment, currentUserId: user.userId)
                                .environmentObject(viewModel)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            Spacer()
            HStack {
                if let _ = userStateViewModel.user, let profilePhoto = userStateViewModel.user?.profilePhoto {
                    Image(uiImage: profilePhoto)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .shadow(radius: 10)
                        .cornerRadius(10)
                        .clipShape(Circle())
                }
            
                ResizableTF(text: $viewModel.userNewComment, height: $height)
                    .frame(height: height)
                    .padding(.horizontal)
                    .background(.white)
                    .cornerRadius(15)
            
                Button {
                    Task {
                        try? await viewModel.addComment(posterUserId: post.user.userId, documentId: post.documentID)
                        hideKeyboard()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(Color.appColorPurple)
                        .frame(width: 10, height: 10)
                        .padding(5)
                }
            }
            .padding()

        }
        .background(Color("Background"))
        .task {
            try? await viewModel.getComments(documentId: post.documentID)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle(post.title)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .primary, dismiss: self.dismiss))
    }
}

//#Preview {
//    PostView(post: PostFeedInstance(title: "Left a note", content: "This is one", documentID: "ULd0biI0Hb1oSZ85BhOW", user: DeveloperPreview.instance.user, profilePicture: UIImage(named: "onepiece")!, book: DeveloperPreview.instance.book, dateEvent: Date()))
//        .environmentObject(UserStateViewModel())
//}

