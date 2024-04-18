//
//  NotificationComponentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/7/24.
//

import SwiftUI

struct NotificationComponentView: View {
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @ObservedObject var viewModel: NotificationsViewModel
    
    var body: some View {
        ScrollView {
            ForEach(0..<viewModel.notifications.count, id: \.self) { index in
                HStack {
                    NavigationLink {
                        TwitterProfileView(userId: viewModel.notifications[index].userId)
                    } label: {
                        Image(uiImage: viewModel.notifications[index].profilePicture)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.notifications[index].displayName)
                            .foregroundColor(.primary)
                            .bold()
                            .padding(.leading, 4)
                        Text(viewModel.notifications[index].message)
                            .foregroundColor(.primary)
                        
                        if let comment = viewModel.notifications[index].comment {
                            Text("\"\(comment)\"")
                                .foregroundColor(.primary)
                                .padding(.leading, 2)
                        }
                        
                        Text(viewModel.notifications[index].dateCreated.timeAgoDisplay())
                            .foregroundColor(.primary)
                            .padding(.leading, 5)
                            .foregroundColor(.black.opacity(0.5))
                    }
                    
                    Spacer()
                    if viewModel.notifications[index].type == .followAccepted &&
                        viewModel.notifications[index].followStatus == .notFollowing {
                        Button {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            viewModel.notifications[index].followStatus = .requestedToFollow
                            let userId = viewModel.notifications[index].userId
                            Task {
                                try await viewModel.requestToFollow(userId: userId)
                            }
                        } label: {
                            Text("Follow")
                                .bold()
                                .frame(width: 60, height: 30)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.appColorPurple)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.clear, lineWidth: 2)
                                )
                        }
                    } else if viewModel.notifications[index].type == .followAccepted &&
                                viewModel.notifications[index].followStatus == .requestedToFollow {
                        Button {
                            viewModel.notifications[index].followStatus = .notFollowing
                            let userId = viewModel.notifications[index].userId
                            Task {
                                try await viewModel.deleteFollowRequest(userId: userId)
                            }
                        } label: {
                            Text("Requested")
                                .bold()
                                .frame(width: 80, height: 30)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.appColorOrange)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.clear, lineWidth: 2)
                                )
                        }
                    } else if viewModel.notifications[index].type == .followAccepted {
                        Button {
                            viewModel.notifications[index].followStatus = .notFollowing
                            let userId = viewModel.notifications[index].userId
                            Task {
                                try await viewModel.unfollowUser(userId: userId)
                            }
                        } label: {
                            Text("Unfollow")
                                .bold()
                                .frame(width: 80, height: 30)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(.black)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.clear, lineWidth: 2)
                                )
                        }
                    } else if viewModel.notifications[index].type == .requestedToFollow {
                        HStack {
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                    Task {
                                        let userId = viewModel.notifications[index].userId
                                        let notiId = viewModel.notifications[index].id
                                        try await viewModel.confirmFollowRequest(userId: userId, notiId: notiId)
                                    }
                                viewModel.notifications[index].type = .followAccepted
                                viewModel.notifications[index].message = " Is now following you!"
                            } label: {
                                Text("Confirm")
                                    .font(.system(size: 14))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(7)
                                    .background(Color.appColorPurple)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                            Button {
                                    Task {
                                        let userId = viewModel.notifications[index].userId
                                        let notiId = viewModel.notifications[index].id
                                        try await viewModel.deleteFollowRequest(userId: userId, notiId: notiId)
                                    }
                            } label: {
                                Text("Delete")
                                    .font(.system(size: 14))
                                    .bold()
                                    .foregroundStyle(.white)
                                    .padding(7)
                                    .background(Color.appColorRed)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                .font(.system(size: 14))
                .frame( maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .refreshable {
            if let user = userStateViewModel.user {
                Task {
                    try await viewModel.getPendingFriendsCount(userId: user.userId)
                    try await viewModel.getNotifications(userId: user.userId)
                }
            }
        }
    }
}

//#Preview {
//    NotificationComponentView()
//}
