//
//  CreateUsernameView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/9/23.
//

import SwiftUI
import FirebaseAuth

typealias BarView<V> = Group<V> where V:View
typealias MainContent<V> = Group<V> where V:View

struct ProfileSetupRootView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @StateObject private var viewModel = ProfileSetupViewRootViewModel()
    
    @State private var showBackButton: Bool = false
    
    var body: some View {
        ZStack {
            Color.appBackgroundColor.ignoresSafeArea()
            if viewModel.isCreatingNewUser {
                VStack {
                    Spacer()
                    Spinner()
                    Spacer()
                }
            } else {
                VStack {
                    ZStack {
                        if viewModel.setProgressIndexStep > 1 {
                            HStack {
                                backButton.padding(.leading, CGFloat(20))
                                Spacer()
                            }
                        }
                        HStack {
                            SetupProfileProgressView(viewModel: viewModel)
                        }
                    }
                    .frame(height: 55)
                    Spacer()
                    ContentSetupView(viewModel: viewModel)
                        .environmentObject(userStateViewModel)
                }
            }
        }
    }
}

struct ContentSetupView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @ObservedObject var viewModel: ProfileSetupViewRootViewModel

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: 0) {
                                UserNameSetupView(viewModel: viewModel)
                                    .frame(width: UIScreen.main.bounds.width)
                                    .id(1)
                            
//                                PrivateAccountSetupView(viewModel: viewModel)
//                                    .frame(width: UIScreen.main.bounds.width)
//                                    .id(2)
                            
                                ProfilePictureView(viewModel: viewModel)
                                    .frame(width: UIScreen.main.bounds.width)
                                    .id(2)
                            
                                DataOfBirthView(viewModel: viewModel)
                                    .environmentObject(userStateViewModel)
                                    .frame(width: UIScreen.main.bounds.width)
                                    .id(3)
                            
//                                SetupSelectedGenresView(viewModel: viewModel, showProfileSetUpView: $showProfileSetUpView)
//                                    .frame(width: UIScreen.main.bounds.width)
//                                    .id(4)
                            
                        }
                        .onChange(of: viewModel.setProgressIndexStep) { newValue in
                            withAnimation(.spring()) {
                                proxy.scrollTo(newValue, anchor: .top)
                            }
                        }
                    }
                 }
                .scrollDisabled(true)
            }
            .frame(maxWidth: .infinity)
        }
//        .fullScreenCover(isPresented: $viewModel.isCreatingNewUser) {
//            NavigationView {
//                ZStack {
//                    Color.appBackgroundColor
//                    Spinner()
//                }
//                .ignoresSafeArea(.all)
//            }
//        }
    }
}

extension ProfileSetupRootView {
    
    private var backButton: some View {
        Button {
            withAnimation {
                viewModel.setProgressIndexStep -= 1
            }
        } label: {
            Image(systemName: "chevron.left")
        }
        .foregroundColor(.white)
        .fontWeight(.bold)
    }
}

struct SetupProfileProgressView: View {
    @ObservedObject var viewModel: ProfileSetupViewRootViewModel
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(1..<4) { index in
                Rectangle()
                    .frame(width: 30, height: 5)
                    .foregroundColor(viewModel.setProgressIndexStep >= index ? .white : .white.opacity(0.5))
                    .cornerRadius(20)
            }
        }
    }
}

struct CreateUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupRootView()
    }
}


struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
