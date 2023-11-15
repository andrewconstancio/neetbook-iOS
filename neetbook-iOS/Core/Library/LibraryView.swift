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
            Text("Library")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .foregroundColor(.primary)
                .fontWeight(.bold)
                .font(.largeTitle)
            HStack(spacing: 40) {
                ForEach(0..<categories.count, id: \.self) { index in
                    ZStack(alignment: .bottom) {
                        if currentIndex == index {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.primary)
                                .matchedGeometryEffect(id: "category_background", in: namespace2)
                                .frame(width: 35, height: 2)
                                .offset(y: 10)
                        }
                        Text(categories[index])
                            .fontWeight(.bold)
                            .foregroundColor(currentIndex == index ? .primary : .primary.opacity(0.5))
                            
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
            GeometryReader { geo in
            VStack {
                // menu
                    Spacer()
                    VStack {
                            // book view
                        if viewModel.isLoading {
                            Spacer()
                            HStack {
                                Spacer()
                                LoadingIndicator(animation: .circleTrim, color: .appColorGreen, speed: .fast)
                                Spacer() 
                            }
                            Spacer()
                        } else {
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
            .onAppear {
                Task {
                    try? await viewModel.getUserBooks()
                }
            }
        }
       
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
