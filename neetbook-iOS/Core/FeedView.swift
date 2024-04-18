//
//  HomeView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

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
                VStack {
                    Spacer()
                    LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
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
        .refreshable {
            Task {
                try? await viewModel.refreshFeed()
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background"))
//        ZStack {
//            VStack {
//                if viewModel.isLoadingFeed {
//                    VStack {
//                        Spacer()
//                        Text("Getting your feed...")
//                            .foregroundColor(.white)
//                            .fontWeight(.bold)
//                        LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
//                        Spacer()
//                        Spacer()
//                    }
//                } else {
//                    if viewModel.post.count > 0 {
//                        ScrollView {
//                            VStack {
//                                ForEach(0..<viewModel.post.count, id: \.self) { index in
//                                    LazyVStack {
//                                        HStack {
//                                            VStack(alignment: .leading) {
//                                                HStack(alignment: .top) {
//                                                    NavigationLink {
//                                                        TwitterProfileView(userId: viewModel.post[index].user.userId)
//                                                    } label: {
//                                                        Image(uiImage: viewModel.post[index].profilePicture)
//                                                            .resizable()
//                                                            .frame(width: 40, height: 40)
//                                                            .clipShape(Circle())
//                                                    }
//                                                    
//                                                    NavigationLink {
//                                                        PostView(post: viewModel.post[index])
//                                                            .environmentObject(userStateViewModel)
//                                                    } label: {
//                                                        VStack(alignment: .leading) {
////                                                            HStack {
//                                                                Text(viewModel.post[index].user.displayname ?? "")
//                                                                    .fontWeight(.bold)
//                                                                    .foregroundColor(.primary)
//
//                                                                Text(viewModel.post[index].title)
//                                                                    .foregroundColor(.primary)
////                                                                    .offset(x: -5)
//                                                                    .font(.system(size: 14))
////                                                            }
//                                                            
////                                                            Text(viewModel.post[index].book.title)
////                                                                .foregroundColor(.primary)
////                                                                .fontWeight(.medium)
////                                                                .frame(alignment: .leading)
////                                                                .lineLimit(1)
//                                                            
//                                                            
////                                                            if viewModel.post[index].content != "" {
////                                                                Text("\"\(viewModel.post[index].content)\"")
////                                                                    .foregroundColor(.primary)
////                                                                    .frame(alignment: .leading)
////                                                                    .font(.system(size: 14))
////                                                                    .lineLimit(1)
////                                                            }
//                                                        }
//                                                    }
//                                                }
//                                                NavigationLink {
//                                                    BookView(book: viewModel.post[index].book)
//                                                } label: {
//                                                    if let image = viewModel.post[index].book.coverPhoto {
//                                                        Image(uiImage: image)
//                                                            .resizable()
//                                                            .frame(width: 80, height: 120)
//                                                            .cornerRadius(5)
//                                                            .shadow(radius: 10)
//                                                    }
//                                                }
//                                            }
//                                            .font(.system(size: 14))
////                                            .padding()
//                                        }
////                                        .frame(height: 120)
////                                        .background(colorScheme == .dark ? .black.opacity(0.4) : .white)
////                                        .clipShape(RoundedRectangle(cornerRadius:10))
////                                        .shadow(radius: 3)
//                                        .frame(maxWidth: .infinity)
//                                        .padding(.horizontal, 8)
//                                        
//                                        if let lastDocID = viewModel.lastDocument?.documentID as String? {
//                                            if viewModel.post[index].documentID == lastDocID {
//                                                ProgressView()
//                                                    .tint(.primary)
//                                                    .onAppear {
//                                                        Task {
//                                                            try await viewModel.getHomeFeed()
//                                                        }
//                                                    }
//                                            }
//                                        }
//                                    }
//                                    Divider()
//                                }
//                            }
//                        }
//                        .refreshable {
//                            Task {
//                                try? await viewModel.getHomeFeed()
//                            }
//                        }
//                        .scrollIndicators(.hidden)
//                    } else {
//                        VStack {
//                            Spacer()
//                            Text("Add some friends to see activites here!")
//                                .foregroundColor(.primary.opacity(0.7))
//                                .fontWeight(.bold)
//                            Spacer()
//                        }
//                    }
//                    Spacer()
//                }
//            }
//            .background(Color("Background"))
        }
//    }
}
