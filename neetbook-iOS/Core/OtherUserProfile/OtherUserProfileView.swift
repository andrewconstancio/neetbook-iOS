//
//  OtherUserProfileIView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/11/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct OtherUserProfileView: View {
    let userId: String
    @StateObject private var viewModel = OtherUserProfileViewModel()
    @State var showFollowListView: Bool = false
    @State var backgroundOffset: CGFloat = 0
    @State var currentIndex = 0
    
    let categories: [String] = ["Activity", "Favorites"]
    @State private var selected: String = "Activity"
    @Namespace private var namespace2
    
    var body: some View {
        ZStack {
            Color.appBackgroundColor.ignoresSafeArea()
            VStack() {
                if viewModel.mainDataLoading {
                    VStack {
                        Spacer()
                        LoadingIndicator(animation: .threeBalls, color: .white, speed: .fast)
                        Spacer()
                    }
                } else {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(viewModel.user?.displayname ?? "")
                                .font(.system(size: 36))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("\(viewModel.user?.username ?? "")#\(viewModel.user?.hashcode ?? "")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.7))
                            
                                HStack {
                                    if viewModel.followingStatus == .following {
                                        Button {
                                            showFollowListView = true
                                        } label: {
                                            HStack(spacing: 5) {
                                                Text("\(viewModel.followingCount)")
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                                    .font(.system(size: 15))

                                                Text("Following")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 15))
                                            }
                                        }
                                        Button {
                                            showFollowListView = true
                                        } label: {
                                            HStack(spacing: 5) {
                                                Text("\(viewModel.followerCount)")
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                                    .font(.system(size: 15))

                                                Text("Followers")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 15))
                                            }
                                        }
                                    } else {
                                        HStack(spacing: 5) {
                                            Text("\(viewModel.followingCount)")
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                                .font(.system(size: 15))
                                            
                                            Text("Following")
                                                .foregroundColor(.white)
                                                .font(.system(size: 15))
                                        }
                                        
                                        HStack(spacing: 5) {
                                            Text("\(viewModel.followerCount)")
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                                .font(.system(size: 15))
                                            
                                            Text("Followers")
                                                .foregroundColor(.white)
                                                .font(.system(size: 15))
                                        }
                                    }
                                }
                                .padding(.top, 10)
                        }
                        Spacer()
                        if let profilePic = viewModel.userProfilePicture {
                            Image(uiImage: profilePic)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.red, lineWidth: 5)
                                )
                                .padding(5.0)
                                .overlay(
                                    Circle()
                                        .stroke(Color.yellow, lineWidth: 5)
                                )
                                .shadow(radius: 20)
                        }
                    }
                    HStack(spacing: 20) {
                        if viewModel.followingStatus == .requestedToFollow {
                            Button {
                                Task {
                                    try await viewModel.deleteFollowRequest(userId: userId)
                                }
                            } label: {
                                Text("Requested")
                                    .frame(width: UIScreen.main.bounds.width / 2)
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .background(Color.appColorCeladon)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                        } else if viewModel.followingStatus == .notFollowing {
                            Button {
                                Task {
                                    try await viewModel.requestToFollow(userId: userId)
                                }
                            } label: {
                                Text("Request To Follow")
                                    .frame(width: UIScreen.main.bounds.width / 2)
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .background(.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                        } else {
                            Button {
                                Task {
                                    try await viewModel.unfollowUser(userId: userId)
                                }
                            } label: {
                                Text("Following")
                                    .frame(width: UIScreen.main.bounds.width / 2)
                                    .fontWeight(.bold)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.white)
                                    .padding(5)
                                    .background(Color.appColorWedge)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.clear, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding()
                    
                    // main user content
                    if viewModel.followingStatus == .following {
                        HStack {
                            ForEach(0..<categories.count, id: \.self) { index in
                                ZStack(alignment: .bottom) {
                                    if currentIndex == index {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white)
                                            .matchedGeometryEffect(id: "category_background", in: namespace2)
                                            .frame(width: 35, height: 2)
                                            .offset(y: 10)
                                    }
                                    Text(categories[index])
                                        .foregroundColor(currentIndex == index ? .white : .white.opacity(0.5))
                                }
                                .frame(width: UIScreen.main.bounds.width / 3, height: 55)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        self.currentIndex = index
                                        self.backgroundOffset = CGFloat(index)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)

                        GeometryReader { geo in
                            VStack {
                                Spacer()
                                VStack {
                                    HStack {
                                        Text("Post here")
                                            .frame(width: geo.size.width)
                                        
                                        if viewModel.favoriteBooks.count > 0 {
                                            ScrollView {
                                                LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                                    ForEach(viewModel.favoriteBooks) { favbook in
                                                        NavigationLink {
                                                            BookView(book: favbook.book)
                                                        } label: {
                                                            AsyncImage(url: URL(string: favbook.book.coverURL)) { image in
                                                                image
                                                                    .resizable()
                                                                    .frame(width: 85, height: 125)
                                                                    .shadow(radius: 10)
                                                                    .cornerRadius(10)
                        
                                                            } placeholder: {
                                                                ProgressView()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .frame(width: geo.size.width)
                                        } else {
                                            VStack {
                                                Text("No books added yet!")
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .fontWeight(.bold)
                                                    .frame(width: geo.size.width)
                                                Spacer()
                                                Spacer()
                                                Spacer()
                                            }
                                        }
                                    }
                                    .offset(x: -(self.backgroundOffset * geo.size.width))
                                    .animation(.default)
                                }
                            }
                        }
                    } else {
                        VStack {
                            Image(systemName: "lock")
                                .font(.system(size: 36))
                                .frame(width: 100, height: 100, alignment: .center)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                }
            }
            .sheet(isPresented: $showFollowListView) {
                if let userId = viewModel.user?.userId {
                    OtherFollowListView(userId: userId)
                }
            }
            .padding()
            .task {
                try? await viewModel.loadInitialUserData(userId: userId)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
//                        SettingsView(showSignInView: $showSignInView)
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}
//
//struct OtherUserProfileIView_Previews: PreviewProvider {
//    static var previews: some View {
//        OtherUserProfileIView()
//    }
//}
