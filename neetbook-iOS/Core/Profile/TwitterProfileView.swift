//
//  TwitterProfileView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/7/24.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct TwitterProfileView: View {

    let userId: String

//    @Binding var showSignInView: Bool
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    // for Dark Mode Adoption..
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.dismiss) private var dismiss
    
    // For Smooth Slide Animation...
    @Namespace var animation
    
    @ObservedObject var viewModel: ProfileViewModel
    
    @State var tabBarOffset: CGFloat = 0
    
    @State var titleOffset: CGFloat = 0
    
    @State var currentTab = "Activity"
    
    @State var offset: CGFloat = 0
    
    @State private var activityHeight: Double = 0.0
    
    init(userId: String) {
        self.userId = userId
        self.viewModel = ProfileViewModel(userId: userId)
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoadingMainData {
                VStack {
                    Spacer()
                    Spacer()
                    LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
                    Spacer()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false, content: {
                    if let user = viewModel.user {
                        VStack(spacing: 15){
                            
                            // Header View...
                            GeometryReader{ proxy -> AnyView in
            
                                // Sticky Header...
                                let minY = proxy.frame(in: .global).minY
            
                                DispatchQueue.main.async {
                                    self.offset = minY
                                }
            
                                return AnyView(
                                    ZStack{
                                        BlurView()
                                            .opacity(blurViewOpacity())
            
                                        // Title View...
                                        VStack(spacing: 5){
                                            Text("")
                                        }
                                    }
                                    .clipped()
                                    .frame(height: minY > 0 ? 90 + minY : nil)
                                    .offset(y: minY > 0 ? -minY : -minY < 80 ? 0 : -minY - 80)
                                )
                            }
                            .frame(height: 80)
                            .zIndex(1)
                               
                            VStack {
                                ProfileHeaderView(user: user)
                                    .environmentObject(viewModel)
                                    .overlay(
                                        GeometryReader{proxy -> Color in
            
                                            let minY = proxy.frame(in: .global).minY
            
                                            DispatchQueue.main.async {
                                                self.titleOffset = minY
                                            }
                                            return Color.clear
                                        }
                                        .frame(width: 0, height: 0)
                                        ,alignment: .top
                                    )
                                
                                
                                if !user.isCurrentUser && viewModel.followingStatus != .following {
                                    VStack {
                                        Image(systemName: "lock")
                                            .font(.system(size: 36))
                                            .frame(width: 100, height: 100, alignment: .center)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                } else {
                                    VStack(spacing: 0){
                                        
                                        ScrollView(.horizontal, showsIndicators: false, content: {
                                            
                                            HStack(spacing: 0){
                                                TabButton(title: "Activity", currentTab: $currentTab, animation: animation)
                                                    .frame(width: UIScreen.main.bounds.width / 2 - 20)
                                                
                                                TabButton(title: "Favorites", currentTab: $currentTab, animation: animation)
                                                    .frame(width: UIScreen.main.bounds.width / 2 - 20)
                                            }
                                        })
                                        
                                        Divider()
                                    }
                                    .padding(.top,30)
                                    .offset(y: tabBarOffset < 90 ? -tabBarOffset + 90 : 0)
                                    .overlay(
                
                                        GeometryReader{reader -> Color in
                
                                            let minY = reader.frame(in: .global).minY
                
                                            DispatchQueue.main.async {
                                                self.tabBarOffset = minY
                                            }
                
                                            return Color.clear
                                        }
                                        .frame(width: 0, height: 0)
                
                                        ,alignment: .top
                                    )
                                    .zIndex(1)
                                    
                                    VStack(spacing: 18){
                                        if currentTab == "Activity" {
                                            if viewModel.isLoadingActivity {
                                                ProgressView()
                                                    .tint(.black)
                                            } else {
                                                ProfileActivityView(activityHeight: $activityHeight, userId: user.userId)
                                                    .environmentObject(userStateViewModel)
                                                    .environmentObject(viewModel)
                                                    .frame(height: activityHeight + 300.0)

                                            }
                                        }
                                        
                                        if currentTab == "Favorites" {
                                            ProfileFavoritesView()
                                                .environmentObject(viewModel)
                                        }
                                    }
                                    .padding(.top)
                                    .zIndex(0)
                                }
                                
                            }
//                            .padding(.horizontal)
                            // Moving the view back if it goes > 80...
                            .zIndex(-offset > 80 ? 0 : 1)
                        }
                    }
                })
                .ignoresSafeArea(.all, edges: .top)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .primary, dismiss: self.dismiss))
        .toolbar {
            if let user = viewModel.user {
                if user.isCurrentUser {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SettingsView()
                                .environmentObject(userStateViewModel)
                        } label: {
                            Image(systemName: "gear")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .background(Color("Background"))
    }
    
    func getTitleTextOffset()->CGFloat{
        
        // some amount of progress for slide effect..
        let progress = 20 / titleOffset
        
        let offset = 60 * (progress > 0 && progress <= 1 ? progress : 1)
        
        return offset
    }
    
    // Profile Shrinking Effect...
    func getOffset()->CGFloat{
        
        let progress = (-offset / 80) * 20
        
        return progress <= 20 ? progress : 20
    }
    
    func getScale()->CGFloat{
        
        let progress = -offset / 80
        
        let scale = 1.8 - (progress < 1.0 ? progress : 1)
        
        // since were scaling the view to 0.8...
        // 1.8 - 1 = 0.8....
        
        return scale < 1 ? scale : 1
    }
    
    func blurViewOpacity()->Double{
        
        let progress = -(offset + 80) / 150
        
        return Double(-offset > 80 ? progress : 0)
    }
}

//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        Home()
//            .preferredColorScheme(.dark)
//    }
//}


// Extending View to get Screen Size...
extension View{
    
    func getRect()->CGRect{
        
        return UIScreen.main.bounds
    }
}

// Tab Button...
struct TabButton: View {
    
    var title: String
    @Binding var currentTab: String
    var animation: Namespace.ID
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View{
        
        Button(action: {
            withAnimation{
                currentTab = title
            }
        }, label: {
            
            // if i use LazyStack then the text is visible fully in scrollview...
            // may be its a bug...
            LazyVStack(spacing: 12){
                
                
                if colorScheme == .dark {
                    Text(title)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(currentTab == title ? Color.white : Color.white.opacity(0.5))
                        .padding(.horizontal)
                } else {
                    Text(title)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(currentTab == title ? Color.appColorPurple : .gray)
                        .padding(.horizontal)
                }
                
                if currentTab == title{
                    
                    Capsule()
                        .fill(Color.appColorPurple)
                        .frame(height: 1.2)
                        .matchedGeometryEffect(id: "TAB", in: animation)
                }
                else{
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 1.2)
                }
            }
        })
    }
}
