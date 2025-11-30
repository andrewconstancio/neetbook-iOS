//
//  FeedViewNew.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//
import SwiftUI
import Shimmer

struct FeedViewNew: View {
    
    /// The environment auth view model.
    @EnvironmentObject var authVM: AuthViewModelNew
    
    /// The environment color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// The feed view model.
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        ScrollView {
            header
            
            if viewModel.isLoadingFeed {
                postLoading
            } else {
                if viewModel.feedPost.isEmpty {
                    noFriends
                } else {
                    mainFeed
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background"))
        .task {
            guard viewModel.feedPost.isEmpty else { return }
            await viewModel.fetchFeed()
        }
        .refreshable {
            Task {
                await viewModel.refreshFeed()
            }
        }
    }
    
    /// The main header.
    private var header: some View {
        HStack {
            Text("Friends Feed")
                .font(.title)
                .foregroundStyle(.primary)
                .bold()
            Spacer()
        }
        .padding()
    }
    
    /// Loading post skeletons.
    private var postLoading: some View {
        ForEach(1..<10, id: \.self) { _ in
            VStack(spacing: 20) {
                // Posters information
                HStack {
                    // Profile image
                    Circle()
                        .frame(width: 40, height: 40)
                    
                    // Display name
                    Rectangle()
                        .frame(width: 100, height: 10)
                        .cornerRadius(5)
                    Spacer()
                }
                HStack {
                    // Book cover
                    Rectangle()
                        .frame(width: 80, height: 120)
                        .cornerRadius(5)
                    
                    // Post content
                    VStack(spacing: 10) {
                        Rectangle()
                            .frame(width: 200, height: 10)
                            .cornerRadius(5)
                        
                        Rectangle()
                            .frame(width: 200, height: 10)
                            .cornerRadius(5)
                    }
                    Spacer()
                }
            }
            .redacted(reason: .placeholder)
            .shimmering()
            .opacity(0.5)
            .padding()
        }
    }
    
    /// View to show if the user has added no friends yet.
    private var noFriends: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("noFriendsView")
                .resizable()
                .frame(width: 250, height: 250)
            
            Text("Add friends to see their post here!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    /// The main post feed for the user.
    private var mainFeed: some View {
        ForEach(viewModel.feedPost) { post in
            LazyVStack {
                
                FeedInstance(post: post)
                    .environmentObject(authVM)
                Divider()
                
                if let lastDocID = viewModel.lastDocument?.documentID as String? {
                    if post.documentID == lastDocID {
                        ProgressView()
                            .tint(.primary)
                            .onAppear {
                                Task {
                                    await viewModel.fetchFeed(showLoading: false)
                                }
                            }
                    }
                }
            }
        }
    }
}
