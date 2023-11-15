//
//  SearchView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            VStack {
//                ScrollView {
                    VStack {
                        if !isEditing {
                            VStack(alignment: .leading) {
                                Text("Search")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .fontWeight(.bold)
                                    .font(.largeTitle)
                                
                            }
                        }
                        
                        
                        VStack(alignment: .leading, spacing: 5) {
                            SearchBarView(searchText: $viewModel.searchText, isEditing: $isEditing)
                             
                            if isEditing {
                                HStack {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewModel.searchType = "books"
                                        }
                                    } label: {
                                        Text("Books & Authors")
                                            .fontWeight(.bold)
                                            .foregroundColor(viewModel.searchType == "books" ? Color.white : Color.black.opacity(0.5))
                                            .padding(10)
                                    }
                                    .background(viewModel.searchType == "books" ? Color.blue : Color.white)
                                    .cornerRadius(15)
                                    
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewModel.searchType = "users"
                                        }
                                    } label: {
                                        Text("Users")
                                            .fontWeight(.bold)
                                            .foregroundColor(viewModel.searchType == "users" ? Color.white : Color.black.opacity(0.5))
                                            .padding(10)
                                    }
                                    .background(viewModel.searchType == "users" ? Color.blue : Color.white)
                                    .cornerRadius(15)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        if viewModel.loadingBooks || viewModel.loadingUsers {
                            VStack {
                                Spacer()
                                Spacer()
                                Spacer()
                                LoadingIndicator(animation: .circleTrim, color: .appColorGreen, speed: .fast)
                                Spacer()
                            }
                        }

                        ScrollView {
                            if viewModel.searchType == "books" {
                                if viewModel.searchBookResults.count > 0 {
                                    ForEach(0..<viewModel.searchBookResults.count, id: \.self) { value in
                                        NavigationLink {
                                            BookView(book: viewModel.searchBookResults[value])
                                        } label: {
                                            HStack {
                                                if let coverPhoto = viewModel.searchBookResults[value].coverPhoto{
                                                    Image(uiImage: coverPhoto)
                                                        .resizable()
                                                        .frame(width: 50, height: 75)
                                                        .shadow(radius: 10)
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
                                } else if viewModel.searchBookResults.count == 0
                                            && !viewModel.loadingBooks
                                            && viewModel.searchText != "" {
                                    noSearchResultsFound
                                }
                            }
                            
                            if viewModel.searchType == "users" {
                                if viewModel.searchUsersResults.count > 0 {
                                    ForEach(viewModel.searchUsersResults, id: \.self) { user in
                                        NavigationLink {
                                            OtherUserProfileIView()
                                        } label: {
                                            HStack {
                                                Image(uiImage: user.profilePicture)
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                                    .shadow(radius: 10)
                                                VStack(alignment: .leading) {
                                                    Text(user.displayName)
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                    
                                                    Text("\(user.username)#\(user.hashcode)")
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
                                } else if viewModel.searchUsersResults.count == 0
                                            && !viewModel.loadingUsers
                                            && viewModel.searchText != "" {
                                    noSearchResultsFound
                                    
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
//        }
    }
}

extension SearchView {
    private var noSearchResultsFound: some View {
        VStack() {
            Text("No results found!")
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        }
        .padding()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
