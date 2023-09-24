//
//  CustomNavBarView.swift
//  SwiftAdvancedLearning
//
//  Created by Andrew Constancio on 7/2/23.
//

import SwiftUI

struct CustomNavBarView<Content:View>: View {
    
    @Environment(\.presentationMode) var presentionMode
    let content: Content
    let showBackButton: Bool
    
    init(showBackButton: Bool, @ViewBuilder content: () -> Content) {
        self.showBackButton = showBackButton
        self.content = content()
    }
    
    var body: some View {
        HStack {
            if showBackButton {
                backButton
            }
            Spacer()
            content
            Spacer()
            if showBackButton {
                backButton
                .opacity(0)
            }
        }
        .padding()
        .accentColor(.white)
        .foregroundColor(.white)
        .font(.headline)
        .background(Color.appBackgroundColor.ignoresSafeArea(edges: .top))
    }
}

struct CustomNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
//            CustomNavBarView(showBackButton: true)
            CustomNavBarView(showBackButton: true) {
                Text("Heeeee")
            }
            Spacer()
        }
        
    }
}

extension CustomNavBarView {
    private var backButton: some View {
        Button {
            presentionMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
//    private var titleSection: some View {
//        VStack(spacing: 4) {
//            Text(title)
//                .font(.title)
//                .fontWeight(.semibold)
//            if let subtitle = subtitle {
//                Text(subtitle)
//            }
//        }
//    }
}
