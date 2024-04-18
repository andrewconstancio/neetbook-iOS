//
//  HomeNew.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 3/31/24.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct HomeView: View {
    
    // enviroment color scheme
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @StateObject private var viewModel = HomeViewModel()
    
    @StateObject var genreViewModel = GenreContentViewModel(genre: "Thriller")

    @State private var isEditing = false
    
    @State private var searchText = ""
    
    @State private var genresListSelectedIndex = 0
    
    let genresList: [String] = ["Home", "Thriller", "History", "Romance", "Fantasy", "Action"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hello,")
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                        if let displayname = userStateViewModel.user?.displayname {
                            Text(displayname)
                                .foregroundColor(.primary)
                                .bold()
                                .font(.system(size: 24))
                        }
                    }
                    Spacer()
//                    Text("Neetbook")
//                         .foregroundColor(.primary)
//                         .fontWeight(.bold)
//                    VStack(alignment: .leading) {
//                        Text("Neetbook")
//                             .foregroundColor(.primary)
//                             .fontWeight(.bold)
//                        
//                        Text("Hello,")
//                            .foregroundColor(.secondary)
//                            .font(.system(size: 20))
//                        if let displayname = userStateViewModel.user?.displayname {
//                            Text(displayname)
//                                .foregroundColor(.primary)
//                                .bold()
//                                .font(.system(size: 24))
//                        }
//                    }
                    Spacer()
                    NavigationLink {
                        NotificationView()
                            .environmentObject(userStateViewModel)
                    } label: {
                        Image(systemName: "bell")
                           .resizable()
                           .frame(width: 20, height: 20)
                           .foregroundColor(Color.primary)
//                           .overlay(
//                                NotificationCountView(value: .constant(2))
//                           )
                           .padding(.trailing, 30)
                           .padding(.top, 10)
                    }
                    if let user = userStateViewModel.user {
                        NavigationLink {
                            TwitterProfileView(userId: user.userId)
                                .environmentObject(userStateViewModel)
                        } label: {
                            if let image = user.profilePhoto {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            }
                        }
                        .offset(x: -5, y: 0)
                    }
                }
                
                SearchBarView(searchText: $viewModel.searchText, isEditing: $isEditing, searchFunction: viewModel.searchAction)
                    .padding(.bottom, 10)
                
                if isEditing {
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
                        .background(viewModel.searchType == "books" ? Color.appColorOrange : Color.white)
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
                        .background(viewModel.searchType == "users" ? Color.appColorOrange : Color.white)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    Divider()
                }
                
                if !viewModel.isSearching {
//                    ScrollView(.horizontal) {
//                        HStack(spacing: 30) {
//                            ForEach(0..<genresList.count, id: \.self) { index in
//                                Button {
//                                    withAnimation(.easeInOut(duration: 0.2)) {
//                                        genresListSelectedIndex = index
//                                    }
//                                } label: {
//                                    if genresListSelectedIndex == index {
//                                        Text(genresList[index])
//                                            .foregroundColor(.white)
//                                            .bold()
//                                            .padding(8)
//                                            .background(Capsule().fill(Color.indigo))
//                                    } else {
//                                        Text(genresList[index])
//                                            .foregroundStyle(.primary)
//                                            .bold()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding(.bottom, 20)
//                    .scrollIndicators(.hidden)
//                    if genresListSelectedIndex == 0 {
                        HomeContentView(viewModel: viewModel)
//                    } else {
//                        GenreContentView(viewModel: genreViewModel)
//                    }
                } else {
                    Text("Search")
                        .foregroundColor(.primary)
                        .bold()
                        if viewModel.loadingBooks {
                            Spacer()
                            HStack {
                                Spacer()
                                LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
                                Spacer()
                            }
                            Spacer()
                        } else {
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
                                                        .frame(width: 90, height: 120)
                                                        .cornerRadius(5)
                                                }
                                                VStack(alignment: .leading) {
                                                    Text(viewModel.searchBookResults[value].title)
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Text(viewModel.searchBookResults[value].author)
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary.opacity(0.5))
                                                        .multilineTextAlignment(.leading)
                                                }
                                                Spacer()
                                            }
                                            .padding()
                                            .frame(height: 140)
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(10)
                                        }
                                    }
                                } else if viewModel.searchBookResults.count == 0
                                            && !viewModel.loadingBooks
                                            && viewModel.searchText != "" {
                                    Text("No Results")
                                        .foregroundColor(.primary)
                                        .bold()
                                }
                            }
                            
                            if viewModel.searchType == "users" {
                                if viewModel.searchUsersResults.count > 0 {
                                        ForEach(viewModel.searchUsersResults, id: \.self) { user in
                                            NavigationLink {
                                                TwitterProfileView(userId: user.id)
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
                                                            .foregroundColor(.primary.opacity(0.5))
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
                                    Text("No Results")
                                        .foregroundColor(.primary)
                                        .bold()
                                }
                            }
                        }
                    }
                Spacer()
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .background(Color("Background"))
    }
}
