//
//  TabButton.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//
import SwiftUI

struct TabButton: View {
    
    /// The title of tab.
    var title: String
    
    /// The `HorizontalTab` associated with the button.
    var tab: HorizontalTab
    
    /// Animation namesplace.
    var animation: Namespace.ID
    
    /// Binding var for the curreent tab.
    @Binding var currentTab: HorizontalTab
    
    /// Environment color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View{
        Button(action: {
            withAnimation {
                currentTab = tab
            }
        }, label: {
            LazyVStack(spacing: 12) {
                if colorScheme == .dark {
                    Text(title)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(currentTab.title == title ? Color.white : Color.white.opacity(0.5))
                        .padding(.horizontal)
                } else {
                    Text(title)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(currentTab.title == title ? Color.appColorPurple : .gray)
                        .padding(.horizontal)
                }
                
                if currentTab.title == title {
                    Capsule()
                        .fill(Color.appColorPurple)
                        .frame(height: 1.2)
                        .matchedGeometryEffect(id: "TAB", in: animation)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 1.2)
                }
            }
        })
    }
}

