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
    @State private var isHide = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                if viewModel.isLoadingFeed {
                    VStack {
                        Spacer()
                        Text("Getting your feed...")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        LoadingIndicator(animation: .circleTrim, color: .black, speed: .fast)
                        Spacer()
                        Spacer()
                    }
                } else {
                    if viewModel.post.count > 0 {
                        ScrollView {
                            VStack {
                                GeometryReader{ reader -> AnyView in
                                    let yAxis = reader.frame(in: .global).minY
                                    if yAxis < 0 && !isHide{
                                        DispatchQueue.main.async {
                                            withAnimation{isHide = true}
                                        }
                                    }
                                    if yAxis > 0 && isHide {
                                        DispatchQueue.main.async {
                                            withAnimation{isHide = false}
                                        }
                                    }
                                    return AnyView(
                                        Text("")
                                            .frame(width: 0, height: 0)
                                    )
                                }
                                .frame(width: 0, height: 0)
                                ForEach(0..<viewModel.post.count, id: \.self) { index in
                                    HStack {
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
                                                        .foregroundColor(.black)

                                                    Text(viewModel.post[index].action)
                                                        .foregroundColor(.black)
                                                        .offset(x: -5)
                                                        .font(.system(size: 14))
                                                }

                                                Text(viewModel.post[index].book.title)
                                                    .foregroundColor(.black)
                                                    .fontWeight(.light)

                                                Text(viewModel.post[index].dateString)
                                                    .fontWeight(.light)
                                                    .fontWeight(.bold)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.black.opacity(0.5))
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
                                        .padding(5)
                                    }
                                    .frame(height: 120)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius:10))
                                    .shadow(radius: 3)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 8)
                                }
                            }
                            .padding(.top, 30)
                            .padding(.bottom, 120)
                        }
                        .toolbar(isHide ? .hidden : .visible)
                        .scrollIndicators(.hidden)
                    } else {
                        VStack {
                            Spacer()
                            Text("Add some friends to see activites here!")
                                .foregroundColor(.black.opacity(0.7))
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showSignInView: .constant(true))
    }
}
