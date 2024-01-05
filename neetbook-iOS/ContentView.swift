//
//  ContentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: String = "Home"
    @State private var tabSelection: TabBarItem = .home
    @Binding var showSignInView: Bool
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection) {
            HomeView(showSignInView: $showSignInView)
                .environmentObject(currentUserViewModel)
                .tabBarItem(tab: TabBarItem.home, selection: $tabSelection)

            SearchView()
                .tabBarItem(tab: TabBarItem.search, selection: $tabSelection)

            NotificationView()
                .tabBarItem(tab: TabBarItem.notificaiton, selection: $tabSelection)

            LibraryView()
                .tabBarItem(tab: TabBarItem.library, selection: $tabSelection)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(tabSelection.title)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ProfileView(showSignInView: $showSignInView)
                        .environmentObject(currentUserViewModel)
                } label: {
                    if let image = currentUserViewModel.profilePicture {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSignInView: .constant(false))
    }
}
