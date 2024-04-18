//
//  NotifcationsView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/11/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct NotificationView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @StateObject private var viewModel = NotificationsViewModel()
    
    @State private var showTabBarItems: Bool = false
    
    @State var loadingNotifcations = true
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if loadingNotifcations {
                VStack {
                    Spacer()
                    Spacer()
                    LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
                    Spacer()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }  else {
                if viewModel.notifications.count > 0 {
                    NotificationComponentView(viewModel: viewModel)
                        .environmentObject(userStateViewModel)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .primary, dismiss: self.dismiss))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
