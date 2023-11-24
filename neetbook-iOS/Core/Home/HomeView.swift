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
                    ScrollView {
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
                                    Text(viewModel.post[index].user.displayname ?? "")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text(viewModel.post[index].action)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(uiImage: viewModel.post[index].bookCoverPicture)
                                    .resizable()
                                    .frame(width: 65, height: 100)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(5)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .frame(height: 110)
                        }
                    }
                    .scrollIndicators(.hidden)
                    Spacer()
                }
            }
            .padding()
            .task {
                try? await viewModel.getHomeFeed()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showSignInView: .constant(true))
    }
}
