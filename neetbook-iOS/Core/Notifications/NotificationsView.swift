//
//  NotifcationsView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/11/23.
//

import SwiftUI
import SwiftfulLoadingIndicators
import Shimmer

struct NotificationView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @StateObject private var viewModel = NotificationsViewModel()
    
    @State private var showTabBarItems: Bool = false
    
    @State var loadingNotifcations = true
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if loadingNotifcations {
                ScrollView {
                    ForEach(0..<11, id: \.self) { _ in
                        HStack {
                            Circle()
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Rectangle()
                                    .frame(width: 100, height: 10)
                                    .cornerRadius(5)
                                
                                Rectangle()
                                    .frame(width: 150, height: 10)
                                    .cornerRadius(5)
                                
                                Rectangle()
                                    .frame(width: 20, height: 10)
                                    .cornerRadius(5)
                            }
                            Spacer()
                        }
                        .frame(height: 80)
                        Divider()
                    }
                }
                .redacted(reason: .placeholder)
                .shimmering()
                .opacity(0.5)
                .padding()
                .frame(maxWidth: .infinity)
                
            }  else {
                if viewModel.notifications.count > 0 {
                    ScrollView {
                        ForEach(0..<viewModel.notifications.count, id: \.self) { index in
                            HStack {
                                NavigationLink {
                                    TwitterProfileView(userId: viewModel.notifications[index].userId)
                                        .environmentObject(userStateViewModel)
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
                                if viewModel.notifications[index].type == .followAccepted
                                    && viewModel.notifications[index].followStatus == .notFollowing {
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
                                } else if viewModel.notifications[index].type == .followAccepted
                                            && viewModel.notifications[index].followStatus == .requestedToFollow {
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
                                } else if viewModel.notifications[index].type == .likedActivity ||
                                        viewModel.notifications[index].type == .newPostComment {
                                    NavigationLink {
                                        if let post = viewModel.notifications[index].post {
                                            PostView(post: post)
                                                .environmentObject(userStateViewModel)
                                        }
                                    } label: {
                                        Image(systemName: "arrow.up.forward.app")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                                            
            //                            Text("Delete")
            //                                .font(.system(size: 14))
            //                                .bold()
            //                                .foregroundStyle(.white)
            //                                .padding(7)
            //                                .background(Color.appColorRed)
            //                                .cornerRadius(5)
            //                                .overlay(
            //                                    RoundedRectangle(cornerRadius: 5)
            //                                        .stroke(Color.clear, lineWidth: 2)
            //                                )
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                            .font(.system(size: 15))
                            .frame( maxWidth: .infinity)
                            
                            Divider()
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .refreshable {
                        if let user = userStateViewModel.user {
                            Task {
                                try await viewModel.getNotifications(userId: user.userId)
                            }
                        }
                    }

                } else {
                    Spacer()
                    Spacer()
                    Text("Nothing to see here!")
                        .frame(maxWidth: .infinity)
                        .bold()
                    Spacer()
                    Spacer()
                }
            }
        }
        .background(Color("Background"))
        .onAppear {
            showTabBarItems = true
            if let user = userStateViewModel.user {
                Task {
                    try await viewModel.getPendingFriendsCount(userId: user.userId)
                    try await viewModel.getNotifications(userId: user.userId)
                    loadingNotifcations = false
                }
            }
        }
        .onDisappear {
            showTabBarItems = false
        }
        .navigationTitle("Notifcations")
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: NavBackButtonView(color: .primary, dismiss: self.dismiss))
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
