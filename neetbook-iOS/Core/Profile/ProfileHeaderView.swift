//
//  ProfileHeaderView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/7/24.
//

import SwiftUI

struct ProfileHeaderView: View {
    let user: DBUser
    
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    @State var showProfileEditView: Bool = false
    
    @State var showFollowListView: Bool = false
    
    var body: some View {
        VStack {
            VStack() {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(user.displayname ?? "")
                            .font(.system(size: 36))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text("\(user.username ?? "")#\(user.hashcode ?? "")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.7))

                        if !user.isCurrentUser && viewModel.followingStatus != .following {
                            HStack {
                                HStack(spacing: 5) {
                                    Text("\(viewModel.followingCount)")
                                        .foregroundColor(.primary)
                                        .fontWeight(.bold)
                                        .font(.system(size: 15))

                                    Text("Following")
                                        .foregroundColor(.primary)
                                        .font(.system(size: 15))
                                }
                                
                                HStack(spacing: 5) {
                                    Text("\(viewModel.followerCount)")
                                        .foregroundColor(.primary)
                                        .fontWeight(.bold)
                                        .font(.system(size: 15))

                                    Text("Followers")
                                        .foregroundColor(.primary)
                                        .font(.system(size: 15))
                                }
                            }
                            .padding(.top, 10)
                        } else {
                            HStack {
                                Button {
                                    showFollowListView = true
                                } label: {
                                    HStack(spacing: 5) {
                                        Text("\(viewModel.followingCount)")
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                            .font(.system(size: 15))

                                        Text("Following")
                                            .foregroundColor(.primary)
                                            .font(.system(size: 15))
                                    }
                                }
                                Button {
                                    showFollowListView = true
                                } label: {
                                    HStack(spacing: 5) {
                                        Text("\(viewModel.followerCount)")
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                            .font(.system(size: 15))

                                        Text("Followers")
                                            .foregroundColor(.primary)
                                            .font(.system(size: 15))
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    Spacer()
                    if let profilePic = user.profilePhoto {
                        Image(uiImage: profilePic)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                             Circle()
                                 .stroke(Color.appColorWedge, lineWidth: 5)
                            )
                            .padding(5.0)
                            .overlay(
                              Circle()
                                .stroke(Color.appColorCeladon, lineWidth: 5)
                            )
                            .shadow(radius: 20)
                    }
                }
            }
            .padding()

            HStack(spacing: 20) {
                if user.isCurrentUser {
                    Button {
                        showProfileEditView = true
                    } label: {
                        Text("Edit Profile")
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .bold()
                            .padding(5)
                            .background(Color.appColorPurple)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.clear, lineWidth: 2)
                            )
                    }
                } else {
                    HStack(spacing: 20) {
                        if viewModel.followingStatus == .requestedToFollow {
                            Button {
                                Task {
                                    try await viewModel.deleteFollowRequest(userId: user.userId)
                                }
                            } label: {
                                Text("Requested")
                                    .frame(width: UIScreen.main.bounds.width / 2)
                                    .bold()
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.appColorPurple)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                        } else if viewModel.followingStatus == .notFollowing {
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                Task {
                                    try await viewModel.requestToFollow(userId: user.userId)
                                }
                            } label: {
                                Text("Request To Follow")
                                    .frame(width: UIScreen.main.bounds.width / 2)
                                    .bold()
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(.black)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                        } else {
                            Button {
                                Task {
                                    try await viewModel.unfollowUser(userId: user.userId)
                                }
                            } label: {
                                Text("Following")
                                    .frame(width: UIScreen.main.bounds.width / 2)
                                    .bold()
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
                }
            }
            .padding()
        }
        .sheet(isPresented: $showFollowListView) {
            FollowListView(userId: user.userId)
//                .onDisappear {
//                    Task {
//                        try? await viewModel.
//                        try? await viewModel.setUserFollowerList(userId: user.userId)
//                    }
//                }
        }
        .sheet(isPresented: $showProfileEditView) {
            EditProfileView(user: user, userUpdated: $viewModel.userUpdated, showProfileEditView: $showProfileEditView)
                .onDisappear {
                    if viewModel.userUpdated {
                        Task {
                            try? await viewModel.fetchUser(userId: user.userId)
                        }
                    }
                }
        }
    }
}

//#Preview {
//    ProfileHeaderView()
//}
