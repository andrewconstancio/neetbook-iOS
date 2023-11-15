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
        TabView {
            HomeView(showSignInView: $showSignInView)
                .environmentObject(currentUserViewModel)
                .tabItem {
                    Image(systemName: TabBarItem.home.iconName)
                }
            
            SearchView()
                .environmentObject(currentUserViewModel)
                .tabItem {
                    Image(systemName: TabBarItem.search.iconName)
                }

            NotifcationsView()
                .tabItem {
                    Image(systemName: TabBarItem.notificaiton.iconName)
                }
            
            LibraryView()
                .tabItem {
                    Image(systemName: TabBarItem.library.iconName)
                }

//            ProfileView(showSignInView: $showSignInView)
//                .tabItem {
//                    Label(TabBarItem.profile.title,
//                          systemImage: TabBarItem.profile.iconName
//                    )
//                }
         }
        .toolbar {
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
        .accentColor(Color.pink)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSignInView: .constant(false))
    }
}
