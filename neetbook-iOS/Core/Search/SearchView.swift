//
//  SearchView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isEditing = false
    @State private var searchType: String = "books"
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack {
                        if !isEditing {
                            Text("Search")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .fontWeight(.bold)
                                .font(.largeTitle)
                        }
                        
                        SearchBarView(searchText: $viewModel.searchText, isEditing: $isEditing)
                        
                        
//                        HStack {
//                            Button {
//                                withAnimation(.easeIn(duration: 0.2)) {
//                                    searchType = "books"
//                                }
//                            } label: {
//                                Text("Books")
//                            }
//                            .foregroundColor(.primary)
//                            .padding(10)
//                            .background(searchType == "books" ? Color.appColorPale : .white)
//                            .cornerRadius(10)
//
//                            Button {
//                                withAnimation(.easeIn(duration: 0.2)) {
//                                    searchType = "users"
//                                }
//                            } label: {
//                                Text("Users")
//                            }
//                            .foregroundColor(.primary)
//                            .padding(10)
//                            .background(searchType == "users" ? Color.appColorPale : .white)
//                            .cornerRadius(10)
//
//                        }
//                        .offset(y: -10)

                        ForEach(0..<viewModel.searchBookResults.count, id: \.self) { value in
                            NavigationLink {
                                BookView(book: viewModel.searchBookResults[value])
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: viewModel.searchBookResults[value].coverURL)) { image in
                                        image
                                            .resizable()
                                            .frame(width: 50, height: 75)
                                            .shadow(radius: 10)

                                    } placeholder: {
                                        ProgressView()
                                    }
                                    VStack(alignment: .leading) {
                                        Text(viewModel.searchBookResults[value].title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(viewModel.searchBookResults[value].author)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
