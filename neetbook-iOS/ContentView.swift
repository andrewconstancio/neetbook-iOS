//
//  ContentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var userStateViewModel = UserStateViewModel()
    
    @State private var selection: String = "Home"
    
    @State private var tabSelection: TabBarItem = .home
    
    var body: some View {
        ZStack {
            if userStateViewModel.userState == .accountNotMade {
                ProfileSetupRootView()
                    .environmentObject(userStateViewModel)
            } else if userStateViewModel.userState == .isLoading {
//                Spacer()
//                Spinner()
//                Spacer()
            }  else {
                NavigationStack {
                    TabView {
                        HomeView()
                            .environmentObject(userStateViewModel)
                            .tabItem {
                                Label("", systemImage: "house")
                            }
                            .badge(userStateViewModel.pendingFriendCount)
                        
                        FeedView()
                            .environmentObject(userStateViewModel)
                            .tabItem {
                                Label("", systemImage: "person.2")
                            }
                        
                        LibraryView()
                            .environmentObject(userStateViewModel)
                            .tabItem {
                                Label("", systemImage: "books.vertical")
                            }
                    }
                    .onAppear {
                        let tabBarAppearance = UITabBarAppearance()
                        tabBarAppearance.configureWithDefaultBackground()
                        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
