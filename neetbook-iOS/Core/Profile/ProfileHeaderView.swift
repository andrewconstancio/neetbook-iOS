//
//  ProfileHeaderView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/7/24.
//

import SwiftUI

struct ProfileHeaderView: View {
    
    /// The `DBUser` that is passed in.
    let user: DBUser
    
    /// The profile view model.
    @ObservedObject var viewModel: ProfileViewModel
    
    /// Flag to show the profile edit view.
    @State var showProfileEditView: Bool = false
    
    /// Flag to show the follow list view.
    @State var showFollowListView: Bool = false
    
    /// Flag if the profile was edited.
    @State var profileEdited = false
    
    var body: some View {
        // User display information
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    displayNameAndUsername
                    followersAndFollowingCounts
                }
                
                Spacer()
                profileImage
            }
        }
        .padding()

        // Edit or follow buttons
        HStack(spacing: 20) {
            if user.isCurrentUser {
                profileEditButton
            } else {
                followButtons
            }
        }
        .padding()
        .sheet(isPresented: $showFollowListView) {
            FollowListView(userId: user.userId)
        }
        .sheet(isPresented: $showProfileEditView) {
            EditProfileView(user: user, userUpdated: $profileEdited, showProfileEditView: $showProfileEditView)
                .onDisappear {
                    if profileEdited {
                        Task {
                            await viewModel.fetchUser()
                        }
                    }
                }
        }
    }
    
    /// Show the users display name and username.
    @ViewBuilder
    private var displayNameAndUsername: some View {
        Text(user.displayname ?? "")
            .font(.system(size: 36))
            .fontWeight(.bold)
            .foregroundColor(.primary)

        Text("\(user.username ?? "")#\(user.hashcode ?? "")")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.primary.opacity(0.7))
    }
    
    /// The followers and following button.
    private var followersAndFollowingCounts: some View {
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
    
    /// The profile image.
    @ViewBuilder
    private var profileImage: some View {
        if let profileURL = user.photoUrl,
            let url = URL(string: profileURL) {
            AsyncCachedImage(url: url) { image in
                image
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
                
            } placeholder: {
                ProgressView()
            }
        }
    }
    
    /// The profile edit button.
    private var profileEditButton: some View {
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
    }
    
    /// Depening on the profile state, the requested, requested to follow, or unfollow status.
    private var followButtons: some View {
        HStack(spacing: 20) {
            if viewModel.followingStatus == .requestedToFollow {
                createFollowTypeButton(name: "Requested", color: .appColorPurple) {
                    Task {
                        await viewModel.deleteFollowRequest()
                    }
                }
            } else if viewModel.followingStatus == .notFollowing {
                createFollowTypeButton(name: "Request To Follow", color: .black) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    Task {
                        await viewModel.unfollowUser()
                    }
                }
            } else {
                createFollowTypeButton(name: "Unfollow", color: .appColorOrange) {
                    Task {
                        await viewModel.unfollowUser()
                    }
                }
            }
        }
        .padding()
    }
    
    /// Creates a follow status button.
    /// - Parameters:
    ///   - name: The name of the button.
    ///   - color: The color of the button.
    ///   - action: The action of the button.
    /// - Returns: A button based on the parameters.
    func createFollowTypeButton(name: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(name)
                .frame(width: UIScreen.main.bounds.width / 2)
                .bold()
                .font(.system(size: 14))
                .foregroundColor(Color.white)
                .padding(5)
                .background(color)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.clear, lineWidth: 1)
                )
        }
    }
}

//#Preview {
//    ProfileHeaderView()
//}
