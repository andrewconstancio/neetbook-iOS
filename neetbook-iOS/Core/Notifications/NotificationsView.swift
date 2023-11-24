//
//  NotifcationsView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/11/23.
//

import SwiftUI

struct NotificationView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    var body: some View {
        ZStack {
            Color.appBackgroundColor.ignoresSafeArea()
            VStack {
                ScrollView {
                    if viewModel.notifications.count > 0 {
                        followRequest
                    } else {
                        VStack {
                            Spacer()
                            Text("Nothing to see here!")
                                .foregroundColor(.white.opacity(0.7))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                    }
                }
                .refreshable {
                    Task {
                        try await viewModel.getUserNotifications()
                    }
                }
            }
            .onAppear {
                Task {
                    try await viewModel.getUserNotifications()
                }
            }
        }
    }
}

extension NotificationView {
    private var followRequest: some View {
        ForEach(viewModel.notifications) { value in
            HStack {
                if let image = value.profileImage {
                    NavigationLink {
                        OtherUserProfileView(userId: value.userId)
                    } label: {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                }
                VStack(alignment: .leading) {
                    Text("\(value.username)#\(value.hashcode)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Requested to follow")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Button {
                    Task {
                        try await viewModel.confirmFollowRequest(userId: value.userId, notiId: value.id)
                    }
                } label: {
                    Text("Confirm")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(7)
                        .background(Color.appColorCambridgeBlue)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.clear, lineWidth: 2)
                        )
                }
                Button {
                    Task {
                        try await viewModel.deleteFollowRequest(userId: value.userId, notiId: value.id)
                    }
                } label: {
                    Text("Delete")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(7)
                        .background(.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.clear, lineWidth: 2)
                        )
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .cornerRadius(10)
        }
    }

}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
