//
//  ProfileView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/9/23.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    if let user = viewModel.user {
                        if let photoUrl = user.photoUrl {
                            AsyncImage(url: URL(string: photoUrl)) { image in
                                image
                                    .resizable()
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .shadow(radius: 20)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        Text(user.displayname ?? "")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(user.username ?? "")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
//                        List {
//                            Text("userId: \(user.userId)")
//
//                            if let displayname = user.displayname {
//                                Text("displayname: \(displayname)")
//                            }
//
//                            if let username = user.username {
//                                Text("username: \(username)")
//                            }
//
//                            if let hashcode = user.hashcode {
//                                Text("hashcode: \(hashcode)")
//                            }
//
//                            if let email = user.email {
//                                Text("email: \(email ?? "")")
//                            }
//
//                            Text("Account Type: \(user.publicAccount ? "Public" : "Private")")
//
//
//                            if let genres = user.selectedGenres {
//                                HStack {
//                                    ForEach(0..<genres.count) { index in
//                                        Text("\(genres[index]), ")
//                                    }
//                                }
//                            }
//                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .task {
                    try? await viewModel.loadCurrentUser()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SettingsView(showSignInView: $showSignInView)
                        } label: {
                            Image(systemName: "gear")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationStack {
            ProfileView(showSignInView: .constant(false))
//        }
    }
}
