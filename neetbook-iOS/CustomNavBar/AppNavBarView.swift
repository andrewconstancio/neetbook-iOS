//
//  AppNavBarView.swift
//  SwiftAdvancedLearning
//
//  Created by Andrew Constancio on 7/2/23.
//

import SwiftUI

struct AppNavBarView: View {
    var body: some View {
        Text("AppNavBarView")
//        CustomNavView {
//            ZStack {
//                Color.orange.ignoresSafeArea()
//                CustomNavLink(destination: Text("Destination")) {
//                    CustomNavLink(destination:
//                        Text("Destination")
//                        .customNavigationTitle("Second screen")
//                        .customNavigationSubtitle("subtitle should be showing!!!")
//                    ) {
//                        Text("Navigate")
//                    }
//                }
//            }
//            .customNavBarItems(title: "New Title", subtitle: "Sub", backButton: true)
//        }
    }
}

struct AppNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        AppNavBarView()
    }
}

extension AppNavBarView {
    private var defaultNavView: some View {
        NavigationView {
            ZStack {
                Color.red.ignoresSafeArea()
                
                NavigationLink {
                    Text("hello")
                        .navigationTitle("Title 2")
                        .navigationBarBackButtonHidden(false)
                } label: {
                    Text("Navigate")
                }
            }
            .navigationTitle("Nav Title Here")
        }
    }
}
