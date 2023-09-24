//
//  CustomNavView.swift
//  SwiftAdvancedLearning
//
//  Created by Andrew Constancio on 7/3/23.
//

import SwiftUI

//typealias TabBarView<V> = Group<V> where V:View
//typealias Content<V> = Group<V> where V:View

struct CustomNavView<BarContent: View, Content: View>: View {
    
    let content: TupleView<(BarView<BarContent>, MainContent<Content>)>
//    let content: Content
    
    init(@ViewBuilder _ content: @escaping () -> TupleView<(BarView<BarContent>, MainContent<Content>)>) {
        self.content = content()
    }
    
    var body: some View {
        let (barContent, content) = self.content.value
        
        NavigationView {
            CustomNavBarContainerView {
                BarView {
                    barContent
                }
                
                MainContent {
                    content
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomNavView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavView {
            BarView {
                Text("Bar Content")
            }
            
            MainContent {
                Color.red.ignoresSafeArea()
            }
        }
//        CustomNavView {
//            Color.red.ignoresSafeArea()
//        }
    }
}

extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
