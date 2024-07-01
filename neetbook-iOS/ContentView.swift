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
    
    @State private var selectedTab = 0
    
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
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .environmentObject(userStateViewModel)
                            .tabItem {
                                Label("", systemImage: "house")
                            }
                            .tag(0)
//                            .badge(userStateViewModel.pendingFriendCount)
                        
                        FeedView()
                            .environmentObject(userStateViewModel)
                            .tabItem {
                                Label("", systemImage: "person.2")
                            }
                            .tag(1)
                        
                        LibraryView()
                            .environmentObject(userStateViewModel)
                            .tabItem {
                                Label("", systemImage: "books.vertical")
                            }
                            .tag(3)
                    }
                    .onAppear {
                        let tabBarAppearance = UITabBarAppearance()
                        tabBarAppearance.configureWithDefaultBackground()
                        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                    }
                    .onChange(of: selectedTab) { newValue in
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
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
