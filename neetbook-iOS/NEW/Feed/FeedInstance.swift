//
//  PostInstanceView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//

import SwiftUI

struct FeedInstance: View {
    
    /// The environment auth view model.
    @EnvironmentObject var authVM: AuthViewModelNew

    /// The post from the users feed.
    var post: PostFeedInstance
    
    /// The environment color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// The post instance view model.
    @StateObject private var viewModel = PostInstanceViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Post user information
            HStack {
                profileImage
                userDisplayNameAndTitle
                Spacer()
            }
            
            // Book information and post content
            HStack {
                bookCover
                postContent
                Spacer()
            }
            
            // Post like button and date created
            HStack {
                likeButton
                likeCount
                Spacer()
                postDate
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
        .padding(.horizontal)
        .padding(.vertical, 20)
    }
    
    /// The profile image and link to the user that posted.
    private var profileImage: some View {
        NavigationLink {
//                    TwitterProfileViewNew(userId: post.user.userId)
//                        .environmentObject(userStateViewModel)
        } label: {
            Image(uiImage: post.profilePicture)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
    }
    
    /// The post users display name and post title.
    @ViewBuilder
    private var userDisplayNameAndTitle: some View {
        VStack(alignment: .leading) {
            Text(post.user.displayname ?? "")
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(post.title)
                .foregroundColor(.primary)
                .font(.system(size: 14))
            
        }
    }
    
    /// The book cover photo.
    private var bookCover: some View {
        NavigationLink {
            BookView(book: post.book)
        } label: {
            if let url = URL(string: post.book.coverURL) {
                AsyncCachedImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 90, height: 140)
                        .cornerRadius(5, corners: .allCorners)
                } placeholder: {
                    ProgressView()
                }
            }
        }
    }
    
    /// Like post button.
    private var likeButton: some View {
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
    }
    
    /// Like count for the post.
    @ViewBuilder
    private var likeCount: some View {
        if viewModel.likes > 0 {
            Text("\(viewModel.likes)")
                .font(.system(size: 14))
                .foregroundStyle(.primary)
                .offset(x: 5)
        }
    }
    
    /// Post date created.
    private var postDate: some View {
        Text(post.dateEvent.timeAgoDisplay())
            .font(.system(size: 14))
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
    }
    
    
    /// The post title, author, and post content. Link to the full post view.
    private var postContent: some View {
        NavigationLink(value: post) {
            VStack(alignment: .leading, spacing: 5) {
                Text(post.book.title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

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
    }
}

