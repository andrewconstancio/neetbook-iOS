//
//  OtherFollowListView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/20/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct OtherFollowListView: View {
    @StateObject private var viewModel = OtherFollowListViewModel()
    let userId: String
    let categories: [String] = ["Following", "Followers"]
    @State var backgroundOffset: CGFloat = 0
    @State var currentIndex = 0
    @Namespace private var namespace2
    
    var body: some View {
        ZStack {
            Color.appBackgroundColor.ignoresSafeArea()
            VStack {
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
                .onAppear {
                    Task {
                        try await viewModel.getFollowerUsers(userId: userId)
                        try await viewModel.getFollowingUsers(userId: userId)
                    }
                }
  
                if viewModel.isLoadingFollowers {
                    VStack {
                        Spacer()
                        LoadingIndicator(animation: .threeBalls, color: .white, speed: .fast)
                        Spacer()
                    }
                } else {
                    GeometryReader { geo in
                        VStack {
                            VStack {
                                HStack {
                                    following
                                        .frame(width: geo.size.width)
                                    followers
                                        .frame(width: geo.size.width)
                                }
                                .offset(x: -(self.backgroundOffset * geo.size.width))
                                .animation(.default)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 10 {
                            if self.backgroundOffset > 0 {
                                withAnimation(.spring()) {
                                    self.currentIndex -= 1
                                }
                                self.backgroundOffset -= 1
                            }
                        } else if value.translation.width < -10 {
                            if self.backgroundOffset < 1 {
                                withAnimation(.spring()) {
                                    self.currentIndex += 1
                                }
                                self.backgroundOffset += 1
                            }
                        }
                    }
            )
        }
    }
}


extension OtherFollowListView {
    private var following: some View {
        VStack {
            ForEach(0..<viewModel.following.count, id: \.self) { index in
                HStack {
                    if let image = viewModel.following[index].profileImage {
                        NavigationLink {
                            OtherUserProfileView(userId: viewModel.following[index].userId)
                        } label: {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("\( viewModel.following[index].displayName)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\( viewModel.following[index].username)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    Spacer()
//                    if  viewModel.following[index].followingStatus == .following {
//                        Button {
//                            viewModel.following[index].setFollowStatus(value: .notFollowing)
//                            Task {
//                                let userId = viewModel.following[index].userId
//                                try await viewModel.unfollowUser(userId: userId)
//                            }
//                        } label: {
//                            Text("Unfollow")
//                                .font(.system(size: 14))
//                                .foregroundColor(.black)
//                                .padding(7)
//                                .background(Color.white)
//                                .cornerRadius(5)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .stroke(Color.clear, lineWidth: 2)
//                                )
//                        }
//                    } else if viewModel.following[index].followingStatus == .requestedToFollow {
//                        Button {
//                            viewModel.following[index].setFollowStatus(value: .notFollowing)
//                            Task {
//                                let userId = viewModel.following[index].userId
//                                try await viewModel.deleteFollowRequest(userId: userId)
//                            }
//                        } label: {
//                            Text("Requested")
//                                .font(.system(size: 14))
//                                .foregroundColor(.black)
//                                .padding(7)
//                                .background(Color.white)
//                                .cornerRadius(5)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .stroke(Color.clear, lineWidth: 2)
//                                )
//                        }
//                    } else {
//                        Button {
//                            viewModel.following[index].setFollowStatus(value: .requestedToFollow)
//                            Task {
//                                let userId = viewModel.following[index].userId
//                                try await viewModel.requestToFollow(userId: userId)
//                            }
//                        } label: {
//                            Text("Follow")
//                                .font(.system(size: 14))
//                                .foregroundColor(.white)
//                                .padding(7)
//                                .background(Color.blue)
//                                .cornerRadius(5)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .stroke(Color.clear, lineWidth: 2)
//                                )
//                        }
//                    }
                }
            }
            Spacer()
        }
        .padding()
    }
    
    private var followers: some View {
        VStack {
            ForEach(0..<viewModel.followers.count, id: \.self) { index in
                HStack {
                    if let image = viewModel.followers[index].profileImage {
                        NavigationLink {
                            OtherUserProfileView(userId: viewModel.followers[index].userId)
                        } label: {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("\(viewModel.followers[index].displayName)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(viewModel.followers[index].username)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    Spacer()
//                    Button {
//                        Task {
//                            let userId = viewModel.followers[index].userId
//                            let instanceId = viewModel.followers[index].id
//                            try await viewModel.removeFollower(userId: userId, instanceId: instanceId)
//                        }
//                    } label: {
//                        Text("Remove")
//                            .font(.system(size: 14))
//                            .foregroundColor(.black)
//                            .padding(7)
//                            .background(Color.white)
//                            .cornerRadius(5)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 5)
//                                    .stroke(Color.clear, lineWidth: 2)
//                            )
//                    }
//                    .offset(x: -23)
                }
            }
            Spacer()
        }
    }
}

//struct OtherFollowListView_Previews: PreviewProvider {
//    static var previews: some View {
//        OtherFollowListView()
//    }
//}
