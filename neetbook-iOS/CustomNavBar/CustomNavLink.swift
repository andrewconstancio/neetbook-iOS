//
//  CustomNavLink.swift
//  SwiftAdvancedLearning
//
//  Created by Andrew Constancio on 7/3/23.
//

import SwiftUI
    
struct CustomNavLink<Label:View, Destination:View>: View {
    
    let destination: Destination
    let label: Label
    
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        NavigationLink(
        destination:
//            CustomNavBarContainerView(content: {
//                destination
//            })
//            .navigationBarHidden(true)) {
//                label
//            }
        CustomNavBarContainerView({
            BarView {
                Text(">>>")
            }
            
            MainContent {
                destination
            }
        })
        .navigationBarHidden(true)) {
            label
        }
    }
}

struct CustomNavLink_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavView {
            
            BarView {
                Text("Bar content")
            }
            
            MainContent {
                CustomNavLink(
                    destination: Text("Destinatio")) {
                        Text("asdf")
                    }
            }
        }
    }
}
