//
//  TestView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/18/23.
//

import SwiftUI

struct FriendsHorizontalScrollView: View {
    var body: some View {
        Text("Horizontal Scroller")
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.green)
    }
}

struct FullHeightView: View {
    var body: some View {
        ZStack {
            Color.red
            Text("Dynamic Content")
        }
        .frame(maxWidth: .infinity)
        .frame(height: .infinity)
    }
}

struct HeaderView: View {
    var body: some View {
        Rectangle().foregroundColor(.blue)
            .frame(height: 60)
            .overlay(Text("Header"))
    }
}

struct TestView: View {
    @State private var height1: CGFloat = .zero
      @State private var height2: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()

            GeometryReader { gp in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        FriendsHorizontalScrollView()
                            .background(GeometryReader {
                                Color.clear
                                    .preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
                            })
                            .onPreferenceChange(ViewHeightKey.self) { self.height1 = $0 }
                        VStack(spacing: 0) {
                            // I want this view to take all the remaining height left in the scrollView
                            FullHeightView()
                                .background(GeometryReader {
                                    Color.clear
                                        .preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
                                })
                        }.frame(height: max(gp.size.height - self.height1, self.height2))
                        .background(Color.yellow)
                    }
                }
                .onPreferenceChange(ViewHeightKey.self) { self.height2 = $0 }
            }
        }.frame(maxWidth: .infinity)
    }

}

struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
