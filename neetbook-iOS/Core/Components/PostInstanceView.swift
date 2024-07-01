//
//  PostView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/7/24.
//

import SwiftUI

struct PostInstanceView: View {
    var post: PostFeedInstance
    
    let linkToPost: Bool
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel = PostInstanceViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // userstack
            HStack {
                NavigationLink {
                    TwitterProfileView(userId: post.user.userId)
                        .environmentObject(userStateViewModel)
                } label: {
                    Image(uiImage: post.profilePicture)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                if linkToPost {
                    NavigationLink {
                        PostView(post: post)
                            .environmentObject(userStateViewModel)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(post.user.displayname ?? "")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(post.title)
                                .foregroundColor(.primary)
                                .font(.system(size: 14))
                        }
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text(post.user.displayname ?? "")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(post.title)
                            .foregroundColor(.primary)
                            .font(.system(size: 14))
                        
                    }
                }
                Spacer()
            }
            // book info stack
            HStack {
                NavigationLink {
                    BookView(book: post.book)
                } label: {
                    if let image = post.book.coverPhoto {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 90, height: 140)
//                            .cornerRadius(5)
                    }
                }
                NavigationLink {
                    PostView(post: post)
                        .environmentObject(userStateViewModel)
                    
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(post.book.title)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        Text(post.book.author)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        if post.content != "" {
                            Text("\"\(post.content)\"")
                                .foregroundColor(.primary)
                                .font(.system(size: 14))
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
            
            // book action stack
            HStack {
                Button {
                    if !viewModel.isLikedByUser {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }
                    Task {
                        await viewModel.updateLikes(for: post)
                    }
                } label: {
                    LikeButton(isLiked: $viewModel.isLikedByUser)
                        .frame(width: 20, height: 20)
                    
                }
                if viewModel.likes > 0 {
                    Text("\(viewModel.likes)")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                        .offset(x: 5)
                }
                Spacer()
                Text(post.dateEvent.timeAgoDisplay())
                    .font(.system(size: 14))
                    .foregroundStyle(.primary)
            }
            .padding(.leading, 4)
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .onAppear {
            Task {
                await viewModel.fetchLikes(for: post.documentID)
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Oops! Something went wrong"), 
                  message: Text(viewModel.errorMessage),
                  dismissButton: .default(Text("OK")))
        }
        .padding()
    }
}

//#Preview {
//    PostView()
//}
