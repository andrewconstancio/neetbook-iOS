//
//  HomeView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//

import SwiftUI
import SwiftfulLoadingIndicators
import Shimmer

struct FeedView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @StateObject private var viewModel = FeedViewModel()
    
    @State private var isHide = false
    
    @State private var showTabBarItems: Bool = false
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Friends Feed")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .bold()
                Spacer()
            }
            .padding()
            
            if viewModel.isLoadingFeed {
                ForEach(1..<10, id: \.self) { _ in
                    postSkeleton
                }
            } else {
                if viewModel.post.isEmpty {
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
                } else {
                    ForEach(viewModel.post) { post in
                        LazyVStack {
                            PostInstanceView(post: post, linkToPost: true)
                                .environmentObject(userStateViewModel)
                            Divider()
                            if let lastDocID = viewModel.lastDocument?.documentID as String? {
                                if post.documentID == lastDocID {
                                    ProgressView()
                                        .tint(.primary)
                                        .onAppear {
                                            Task {
                                                try await viewModel.getFeed()
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            Task {
                try? await viewModel.refreshFeed()
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background"))
    }
}

extension FeedView {
    private var postSkeleton: some View {
        VStack(spacing: 20) {
            HStack {
                Circle()
                    .frame(width: 40, height: 40)
                
                Rectangle()
                    .frame(width: 100, height: 10)
                    .cornerRadius(5)
                Spacer()
            }
            HStack {
                Rectangle()
                    .frame(width: 80, height: 120)
                    .cornerRadius(5)
                
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
