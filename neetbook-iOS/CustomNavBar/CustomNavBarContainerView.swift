//
//  CustomNavBarContainerView.swift
//  SwiftAdvancedLearning
//
//  Created by Andrew Constancio on 7/3/23.
//

import SwiftUI


struct CustomNavBarContainerView<BarContent:View, Content:View>: View {
    
    let content: TupleView<(BarView<BarContent>, MainContent<Content>)>
    @State var showBackButton: Bool = true
    @State private var title: String = ""
    @State private var subtitle: String? = nil
    
    init(@ViewBuilder _ content: @escaping () -> TupleView<(BarView<BarContent>, MainContent<Content>)>) {
        self.content = content()
    }
    
    var body: some View {
        let (barContent, content) = self.content.value
        
        VStack(spacing: 0){

            CustomNavBarView(showBackButton: showBackButton) {
                barContent
            }
            content.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onPreferenceChange(CustomNavbarTitlePreferenceKey.self ) { value in
            self.title = value
        }
        .onPreferenceChange(CustomNavbarSubTitlePreferenceKey.self ) { value in
            self.subtitle = value
        }
        .onPreferenceChange(CustomNavbarBackButtonHiddenPreferenceKey.self ) { value in
            self.showBackButton = !value
        }
    }
}

struct CustomNavBarContainerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavBarContainerView {
            BarView {
                Text("Hello")
            }
            MainContent {
                ZStack {
                   Color.green.ignoresSafeArea()
   
                   Text("Hello")
                       .foregroundColor(.white)
                       .customNavigationTitle("new title")
                       .customNavigationSubtitle("sub")
                       .customNavigationBarBackButtonHidden(true)
               }
            }
        }
//        CustomNavBarContainerView(barContent: Text("Hello")) {
//            ZStack {
//                Color.green.ignoresSafeArea()
//
//                Text("Hello")
//                    .foregroundColor(.white)
//                    .customNavigationTitle("new title")
//                    .customNavigationSubtitle("sub")
//                    .customNavigationBarBackButtonHidden(true)
//            }
//        }
//        CustomNavBarContainerView() {
//            ZStack {
//                Color.green.ignoresSafeArea()
//
//                Text("Hello")
//                    .foregroundColor(.white)
//                    .customNavigationTitle("new title")
//                    .customNavigationSubtitle("sub")
//                    .customNavigationBarBackButtonHidden(true)
//            }
//        }
    }
}
