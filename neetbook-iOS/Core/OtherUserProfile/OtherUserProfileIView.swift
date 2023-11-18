//
//  OtherUserProfileIView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/11/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct OtherUserProfileIView: View {
    let userId: String
    @StateObject private var viewModel = OtherUserProfileViewModel()
    
    var body: some View {
        VStack() {
            if viewModel.userDataLoading {
                VStack {
                    Spacer()
                    LoadingIndicator(animation: .threeBalls, color: .appColorGreen, speed: .fast)
                    Spacer()
                }
            } else {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(viewModel.user?.displayname ?? "")
                            .font(.system(size: 36))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("\(viewModel.user?.username ?? "")#\(viewModel.user?.hashcode ?? "")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.7))
                        
                        HStack {
                            HStack(spacing: 5) {
                                Text("50")
                                    .foregroundColor(.primary)
                                    .fontWeight(.bold)
                                    .font(.system(size: 15))
                                
                                Text("Followers")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 15))
                            }
                            
                            HStack(spacing: 5) {
                                Text("12")
                                    .foregroundColor(.primary)
                                    .fontWeight(.bold)
                                    .font(.system(size: 15))
                                
                                Text("Following")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 15))
                            }
                        }
                        .padding(.top, 10)
                    }
                    Spacer()
                    if let profilePic = viewModel.userProfilePicture {
                        Image(uiImage: profilePic)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.red, lineWidth: 5)
                            )
                            .padding(5.0)
                            .overlay(
                                Circle()
                                    .stroke(Color.yellow, lineWidth: 5)
                            )
                            .shadow(radius: 20)
                    }
                }
            }
        }
        .padding()
        .task {
            try? await viewModel.getUserData(userId: userId)
        }
    }
}
//
//struct OtherUserProfileIView_Previews: PreviewProvider {
//    static var previews: some View {
//        OtherUserProfileIView()
//    }
//}
