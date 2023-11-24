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
            Color.appBackgroundColor.ignoresSafeArea()
            ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 5) {
                    SearchBarView(searchText: $viewModel.searchText, isEditing: $isEditing)
                     
//                    if isEditing {
                        HStack {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.searchType = "books"
                                    viewModel.searchText = ""
                                }
                            } label: {
                                Text("Books & Authors")
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.searchType == "books" ? Color.white : Color.black.opacity(0.5))
                                    .padding(10)
                            }
                            .background(viewModel.searchType == "books" ? Color.appColorCambridgeBlue : Color.white)
                            .cornerRadius(15)
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.searchType = "users"
                                    viewModel.searchText = ""
                                }
                            } label: {
                                Text("Users")
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.searchType == "users" ? Color.white : Color.black.opacity(0.5))
                                    .padding(10)
                            }
                            .background(viewModel.searchType == "users" ? Color.appColorCambridgeBlue : Color.white)
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
//                }
                
                if viewModel.loadingBooks || viewModel.loadingUsers {
                    Spacer()
                    Spacer()
                    LoadingIndicator(animation: .circleTrim, color: .white, speed: .fast)
                    Spacer()
                }

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
                                                .frame(width: 60, height: 100)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(viewModel.searchBookResults[value].title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text(viewModel.searchBookResults[value].author)
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.5))
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
                                        OtherUserProfileView(userId: user.id)
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
                                                    .foregroundColor(.white)
                                                
                                                Text("\(user.username)#\(user.hashcode)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                            Spacer()
                                        }
                                        .padding()
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
                .padding(.bottom, 120)
            }
            Spacer()
        }
    }
}

extension SearchView {
    private var noSearchResultsFound: some View {
        VStack() {
            Text("No results found!")
                .foregroundColor(.white.opacity(0.7))
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
