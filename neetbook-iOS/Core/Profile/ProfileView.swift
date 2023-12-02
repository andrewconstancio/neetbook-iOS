//
//  ProfileView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/9/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State var showProfileEditView: Bool = false
    @State var showFollowListView: Bool = false
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel

    @State var backgroundOffset: CGFloat = 0
    @State var currentIndex = 0
    
    let categories: [String] = ["Activity", "Favorites"]
    @State private var selected: String = "Activity"
    @Namespace private var namespace2
    
    var body: some View {
        ZStack {
            Color.appBackgroundColor.ignoresSafeArea()
            VStack() {
                VStack() {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(viewModel.user?.displayname ?? "")
                                    .font(.system(size: 36))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text("\(viewModel.user?.username ?? "")#\(viewModel.user?.hashcode ?? "")")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.7))

                                HStack {
                                    Button {
                                        showFollowListView = true
                                    } label: {
                                        HStack(spacing: 5) {
                                            Text("\(viewModel.followingCount)")
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                                .font(.system(size: 15))

                                            Text("Following")
                                                .foregroundColor(.white)
                                                .font(.system(size: 15))
                                        }
                                    }
                                    Button {
                                        showFollowListView = true
                                    } label: {
                                        HStack(spacing: 5) {
                                            Text("\(viewModel.followerCount)")
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                                .font(.system(size: 15))

                                            Text("Followers")
                                                .foregroundColor(.white)
                                                .font(.system(size: 15))
                                        }
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
                                         .stroke(Color.appColorWedge, lineWidth: 5)
                                    )
                                    .padding(5.0)
                                    .overlay(
                                      Circle()
                                        .stroke(Color.appColorCeladon, lineWidth: 5)
                                    )
                                    .shadow(radius: 20)
                            }
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
                            .foregroundColor(.black)
                            .padding(5)
                            .background(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.clear, lineWidth: 2)
                            )
                    }
                    NavigationLink {
                        SettingsView(showSignInView: $showSignInView)
                    } label: {
                        Text("Share Profile")
                            .frame(width: UIScreen.main.bounds.width / 3)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .padding(5)
                            .background(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.clear, lineWidth: 2)
                            )
                    }
                }
                .padding()
                
                HStack {
                    ForEach(0..<categories.count, id: \.self) { index in
                        ZStack(alignment: .bottom) {
                            if currentIndex == index {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .matchedGeometryEffect(id: "category_background", in: namespace2)
                                    .frame(width: 35, height: 2)
                                    .offset(y: 10)
                            }
                            Text(categories[index])
                                .foregroundColor(currentIndex == index ? .white : .white.opacity(0.5))
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
                                if viewModel.activity.count > 0 {
                                    ScrollView {
                                        VStack(alignment: .leading){
                                            ForEach(0..<viewModel.activity.count, id: \.self) { index in
                                                HStack {
                                                    VStack(alignment: .leading) {
                                                        HStack {
                                                            Text("You")
                                                                .fontWeight(.bold)
                                                                .foregroundColor(.white)
                                                            
                                                            Text(viewModel.activity[index].action)
                                                                .foregroundColor(.white)
                                                        }
                                                        
                                                        Text(viewModel.activity[index].book.title)
                                                            .foregroundColor(.white)
                                                            .fontWeight(.bold)
                                                        
                                                        Text("by \(viewModel.activity[index].book.author)")
                                                            .foregroundColor(.white)
                                                        
                                                        Text(viewModel.activity[index].dateString)
                                                            .fontWeight(.light)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white.opacity(0.5))
                                                    }
                                                    Spacer()
                                                    NavigationLink {
                                                        BookView(book: viewModel.activity[index].book)
                                                    } label: {
                                                        Image(uiImage: viewModel.activity[index].bookCoverPicture)
                                                            .resizable()
                                                            .frame(width: 65, height: 100)
                                                            .cornerRadius(10)
                                                            .shadow(radius: 10)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .frame(width: geo.size.width)
                                } else {
                                    VStack {
                                        Text("No activity yet!")
                                            .foregroundColor(.white.opacity(0.7))
                                            .fontWeight(.bold)
                                            .frame(width: geo.size.width)
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                    }
                                }
                                
                                if viewModel.favoriteBooks.count > 0 {
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
                                                            .cornerRadius(10)
                
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: geo.size.width)
                                } else {
                                    VStack {
                                        Text("No books added yet!")
                                            .foregroundColor(.white.opacity(0.7))
                                            .fontWeight(.bold)
                                            .frame(width: geo.size.width)
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                    }
                                }
                            }
                            .offset(x: -(self.backgroundOffset * geo.size.width))
                            .animation(.default)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showFollowListView) {
            if let userId = viewModel.user?.userId {
                FollowListView(userId: userId)
                    .onDisappear {
                        Task {
                            try? await viewModel.loadCurrentUser()
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
                        .foregroundColor(.white)
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
