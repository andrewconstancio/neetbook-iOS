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
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(TabBarItem.home.title,
                          systemImage: TabBarItem.home.iconName
                    )
                }

            LibraryView()
                .tabItem {
                    Label(TabBarItem.library.title,
                          systemImage: TabBarItem.library.iconName
                    )
                }

            SearchView()
                .tabItem {
                    Label(TabBarItem.search.title,
                          systemImage: TabBarItem.search.iconName
                    )
                }

            ProfileView(showSignInView: $showSignInView)
                .tabItem {
                    Label(TabBarItem.profile.title,
                          systemImage: TabBarItem.profile.iconName
                    )
                }
         }
        .accentColor(Color.pink)
        .ignoresSafeArea(.keyboard, edges: .bottom)
//        CustomTabBarContainerView(selection: $tabSelection) {
//            HomeView()
//                .tabBarItem(tab: .home, selection: $tabSelection)
//
//            LibraryView()
//                .tabBarItem(tab: .library, selection: $tabSelection)
//
//            SearchView()
//                .tabBarItem(tab: .search, selection: $tabSelection)
//
//            ProfileView(showSignInView: $showSignInView)
//                .tabBarItem(tab: .profile, selection: $tabSelection)
//        }
//        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSignInView: .constant(false))
    }
}
