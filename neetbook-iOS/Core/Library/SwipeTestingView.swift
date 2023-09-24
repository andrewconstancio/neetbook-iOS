//
//  SwipeTestingView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/20/23.
//

import SwiftUI

struct SwipeTestingView: View {
    
    @State var backgroundOffset: CGFloat = 0
    @State var currentIndex = 0
    
    let categories: [String] = ["Reading", "Want To Read", "Read"]
    @State private var selected: String = "Reading"
    @Namespace private var namespace2
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<categories.count) { index in
                    ZStack(alignment: .bottom) {
                            if currentIndex == index {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.primary)
                                    .matchedGeometryEffect(id: "category_background", in: namespace2)
                                    .frame(width: 35, height: 2)
                                    .offset(y: 10)
                            }
                            Text(categories[index])
                                .foregroundColor(currentIndex == index ? .primary : .primary.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            self.currentIndex = index
                            self.backgroundOffset = CGFloat(index)
                        }
                    }
                }
            }
            .padding()
            
            GeometryReader { geo in
                HStack {
                    ZStack {
                        VStack {
//                            LibraryReadingView(viewModel: viewMode)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    
                    ZStack {
                        VStack {
                            Text("Want To Read")
                                .foregroundColor(.black)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    
                    ZStack {
                        VStack {
                            Text("Read")
                                .foregroundColor(.black)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .offset(x: -(self.backgroundOffset * geo.size.width))
                .animation(.default)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 10 {
                            if self.backgroundOffset > 0 {
                                withAnimation(.spring()) {
                                    self.currentIndex -= 1
                                }
                                self.backgroundOffset -= 1
                            }
                        } else if value.translation.width < -10 {
                            if self.backgroundOffset < 2 {
                                withAnimation(.spring()) {
                                    self.currentIndex += 1
                                }
                                self.backgroundOffset += 1
                            }
                        }
                    }
            )
        }
    }
        
}

struct SwipeTestingView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeTestingView()
    }
}
