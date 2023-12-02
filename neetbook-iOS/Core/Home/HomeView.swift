//
//  HomeView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct HomeView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            Color.appBackgroundColor.ignoresSafeArea()
            VStack {
                if viewModel.isLoadingFeed {
                    VStack {
                        Spacer()
                        Text("Getting your feed...")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        LoadingIndicator(animation: .circleTrim, color: .white, speed: .fast)
                        Spacer()
                        Spacer()
                    }
                } else {
                    if viewModel.post.count > 0 {
                        ScrollView {
                            VStack {
                                ForEach(0..<viewModel.post.count, id: \.self) { index in
                                    HStack {
                                        NavigationLink {
                                            OtherUserProfileView(userId: viewModel.post[index].user.userId)
                                        } label: {
                                            Image(uiImage: viewModel.post[index].profilePicture)
                                                .resizable()
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                                .shadow(radius: 10)
                                        }
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text(viewModel.post[index].user.displayname ?? "")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                
                                                Text(viewModel.post[index].action)
                                                    .foregroundColor(.white)
                                                    .offset(x: -5)
                                                    .font(.system(size: 14))
                                            }
                                            
                                            Text(viewModel.post[index].book.title)
                                                .foregroundColor(.white)
                                                .fontWeight(.light)
                                            
                                            Text(viewModel.post[index].dateString)
                                                .fontWeight(.light)
                                                .fontWeight(.bold)
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        Spacer()
                                        NavigationLink {
                                            BookView(book: viewModel.post[index].book)
                                        } label: {
                                            if let image = viewModel.post[index].book.coverPhoto {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .frame(width: 65, height: 100)
                                                    .cornerRadius(10)
                                                    .shadow(radius: 10)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .frame(height: 120)
                                    .background(Color.appColorBeige.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius:10))
                                    .frame(maxWidth: .infinity)
                                    .shadow(radius: 10)
                                }
                            }
                            .padding(.bottom, 120)
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        VStack {
                            Spacer()
                            Text("Add some friends to see activites here!")
                                .foregroundColor(.white.opacity(0.7))
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            .padding(5)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showSignInView: .constant(true))
    }
}
