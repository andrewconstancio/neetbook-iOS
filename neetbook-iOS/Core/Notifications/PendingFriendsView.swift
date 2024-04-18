//
//  PendingFriendsView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/5/24.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct PendingFriendsView: View {
    @StateObject private var viewModel = PendingFriendsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ScrollView {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        LoadingIndicator(animation: .threeBalls, color: .primary, speed: .fast)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    if viewModel.followRequest.count > 0 {
                        followRequest
                    } else {
                        VStack {
                            Spacer()
                            Text("Nothing to see here!")
                                .foregroundColor(.primary.opacity(0.7))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                    }
                }
            }
            .refreshable {
                Task {
                    try await viewModel.setup()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Pending Follow Request")
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .primary, dismiss: self.dismiss))
    }
}

extension PendingFriendsView {
    private var followRequest: some View {
        ForEach(viewModel.followRequest) { value in
            HStack {
                if let image = value.profileImage {
                    NavigationLink {
                        TwitterProfileView(userId: value.userId)
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
                        .foregroundColor(.primary)
                    
                    Text("Requested to follow")
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.7))
                }
                Spacer()
                Button {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    Task {
                        try await viewModel.confirmFollowRequest(userId: value.userId, notiId: value.id)
                    }
                } label: {
                    Text("Confirm")
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

#Preview {
    PendingFriendsView()
}
