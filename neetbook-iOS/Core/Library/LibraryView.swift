//
//  LibraryView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//

import SwiftUI
import SnapToScroll
import SwiftfulLoadingIndicators

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    
    @State var backgroundOffset: CGFloat = 0
    @State var currentIndex = 0
    
    let categories: [String] = ["Reading", "Want To Read", "Read"]
    @State private var selected: String = "Reading"
    @Namespace private var namespace2
    
    var body: some View {
        VStack {
            HStack(spacing: 40) {
                ForEach(0..<categories.count, id: \.self) { index in
                    ZStack(alignment: .bottom) {
                        if currentIndex == index {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                                .matchedGeometryEffect(id: "category_background", in: namespace2)
                                .frame(width: 55, height: 2)
                                .offset(y: 10)
                        }
                        Text(categories[index])
                            .fontWeight(.bold)
                            .foregroundColor(currentIndex == index ? .black : .black.opacity(0.5))
                            
                    }
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
            
            if viewModel.isLoading {
                Spacer()
                VStack {
                    Spacer()
                    LoadingIndicator(animation: .circleTrim, color: .black, speed: .fast)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        VStack {
                            HStack {
                                LibraryBookListView(bookList: viewModel.booksReading)
                                    .frame(width: geo.size.width)
                                
                                LibraryBookListView(bookList: viewModel.booksWantToRead)
                                    .frame(width: geo.size.width)
                                
                                LibraryBookListView(bookList: viewModel.booksRead)
                                    .frame(width: geo.size.width)

                            }
                            .offset(x: -(self.backgroundOffset * geo.size.width))
                            .animation(.default)
                        }
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            Task {
                try? await viewModel.getUserBooks()
            }
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

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
