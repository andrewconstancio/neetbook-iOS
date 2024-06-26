//
//  FollowListView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/19/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct FollowListView: View {
    @StateObject private var viewModel = FollowListViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    let userId: String
    
    let categories: [String] = ["Following", "Followers"]
    
    @State var backgroundOffset: CGFloat = 0
    
    @State var currentIndex = 0
    
    @Namespace private var namespace2
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<categories.count, id: \.self) { index in
                    ZStack(alignment: .bottom) {
                        if currentIndex == index {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                                .matchedGeometryEffect(id: "category_background", in: namespace2)
                                .frame(width: 35, height: 2)
                                .offset(y: 10)
                        }
                        
                        if colorScheme == .dark {
                            Text(categories[index])
                                .bold()
                                .foregroundColor(currentIndex == index ? .white : .white.opacity(0.5))
                        } else {
                            Text(categories[index])
                                .bold()
                                .foregroundColor(currentIndex == index ? .black : .black.opacity(0.5))
                        }
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

            if viewModel.isLoadingFollowers {
                VStack {
                    Spacer()
                    ProgressView()
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
        .task {
            try? await viewModel.getAllFollowData(userId: userId)
        }
        .background(Color("Background"))
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

extension FollowListView {
    private var following: some View {
        VStack {
            if viewModel.following.count > 0 {
                ForEach(0..<viewModel.following.count, id: \.self) { index in
                    HStack {
                        if let image = viewModel.following[index].profileImage {
                            NavigationLink {
                                TwitterProfileView(userId: viewModel.following[index].userId)
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
                                .foregroundColor(.primary)
                            Text("\( viewModel.following[index].username)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        if  viewModel.following[index].followingStatus == .following {
                            Button {
                                viewModel.following[index].setFollowStatus(value: .notFollowing)
                                Task {
                                    let userId = viewModel.following[index].userId
                                    try await viewModel.unfollowUser(userId: userId)
                                }
                            } label: {
                                Text("Unfollow")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .padding(7)
                                    .background(Color.white)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                        } else if viewModel.following[index].followingStatus == .requestedToFollow {
                            Button {
                                viewModel.following[index].setFollowStatus(value: .notFollowing)
                                Task {
                                    let userId = viewModel.following[index].userId
                                    try await viewModel.deleteFollowRequest(userId: userId)
                                }
                            } label: {
                                Text("Requested")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .padding(7)
                                    .background(Color.white)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                        } else {
                            Button {
                                viewModel.following[index].setFollowStatus(value: .requestedToFollow)
                                Task {
                                    let userId = viewModel.following[index].userId
                                    try await viewModel.requestToFollow(userId: userId)
                                }
                            } label: {
                                Text("Follow")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(7)
                                    .background(Color.appColorPurple)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
            } else {
                Text("No one to see here!")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
    }
    
    private var followers: some View {
        VStack {
            if viewModel.followers.count > 0 {
                ForEach(0..<viewModel.followers.count, id: \.self) { index in
                    HStack {
                        if let image = viewModel.followers[index].profileImage {
                            NavigationLink {
                                TwitterProfileView(userId: viewModel.following[index].userId)
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
                                .foregroundColor(.primary)
                            Text("\(viewModel.followers[index].username)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Button {
                            Task {
                                let userId = viewModel.followers[index].userId
                                let instanceId = viewModel.followers[index].id
                                try await viewModel.removeFollower(userId: userId, instanceId: instanceId)
                            }
                        } label: {
                            Text("Remove")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .padding(7)
                                .background(Color.white)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.clear, lineWidth: 2)
                                )
                        }
                        .offset(x: -23)
                    }
                }
            } else {
                Text("No one to see here!")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.black)
            }
            Spacer()
        }
    }
}

//struct FollowListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FollowListView()
//    }
//}
