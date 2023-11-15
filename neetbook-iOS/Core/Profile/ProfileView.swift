//
//  ProfileView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/9/23.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State var showProfileEditView: Bool = false
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel

    @State var backgroundOffset: CGFloat = 0
    @State var currentIndex = 0
    
    let categories: [String] = ["Post", "Favorites"]
    @State private var selected: String = "Updates"
    @Namespace private var namespace2
    
    var body: some View {
        NavigationView {
            VStack() {
                VStack() {
//                    if let user = viewModel.user {
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
                            if let profilePic = currentUserViewModel.profilePicture {
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
//                            AsyncImage(url: URL(string: viewModel.photoURL)) { image in
//                                image
//                                    .resizable()
//                                    .frame(width: 100, height: 100)
//                                    .clipShape(Circle())
//                                    .overlay(
//                                     Circle()
//                                         .stroke(Color.red, lineWidth: 5)
//                                    )
//                                    .padding(5.0)
//                                    .overlay(
//                                      Circle()
//                                          .stroke(Color.yellow, lineWidth: 5)
//                                    )
//                                    .shadow(radius: 20)
//                            } placeholder: {
//                                ProgressView()
//                            }
                        }
                }
                .padding()
    
                HStack(spacing: 20) {
                    Button {
                        showProfileEditView = true
                    } label: {
                        Text("Edit Profile")
                            .frame(width: UIScreen.main.bounds.width / 3)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primary, lineWidth: 2)
                            )
                    }
                    NavigationLink {
                        SettingsView(showSignInView: $showSignInView)
                    } label: {
                        Text("Share Profile")
                            .frame(width: UIScreen.main.bounds.width / 3)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primary, lineWidth: 2)
                            )
                    }
                }
                .padding()
                
                HStack {
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
                                .foregroundColor(currentIndex == index ? .primary : .primary.opacity(0.5))
                        }
                        .frame(width: UIScreen.main.bounds.width / 3, height: 55)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                self.currentIndex = index
                                self.backgroundOffset = CGFloat(index)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
  
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        VStack {
                            HStack {
                                Text("Post here")
                                    .frame(width: geo.size.width)
                                
                                ScrollView {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                        ForEach(viewModel.favoriteBooks) { favbook in
                                            NavigationLink {
                                                BookView(book: favbook.book)
                                            } label: {
                                                AsyncImage(url: URL(string: favbook.book.coverURL)) { image in
                                                    image
                                                        .resizable()
                                                        .frame(width: 85, height: 125)
                                                        .shadow(radius: 10)
            
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(width: geo.size.width)
                            }
                            .offset(x: -(self.backgroundOffset * geo.size.width))
                            .animation(.default)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showProfileEditView) {
            if let user = viewModel.user {
                EditProfileView(user: user, showProfileEditView: $showProfileEditView)
                    .environmentObject(currentUserViewModel)
                    .onDisappear {
                        Task {
                            try? await viewModel.loadCurrentUser()
                            try? await viewModel.getPhotoURL()
                        }
                    }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
            try? await viewModel.getPhotoURL()
        }
        .onAppear {
            Task {
                try? await viewModel.getFavoriteBooks()
            }

            Utilities.shared.hideToolBarBackground()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                        .foregroundColor(.primary)
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
                        if self.backgroundOffset < 1 {
                            withAnimation(.spring()) {
                                self.currentIndex += 1
                            }
                            self.backgroundOffset += 1
                        }
                    }
                }
        )
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
////        NavigationStack {
////            ProfileView(showSignInView: .constant(false))
////        }
//    }
//}
