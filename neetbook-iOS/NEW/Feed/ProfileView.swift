//
//  TwitterProfileViewNew.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//
import SwiftUI
import SwiftfulLoadingIndicators
import Shimmer

struct ProfileView: View {

    /// The users ID that is passed in for the profiles information.
    let userID: String

    /// The environment auth view model.
    @EnvironmentObject var authVM: AuthViewModel
    
    /// The environment color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    /// The environment dismiss view.
    @Environment(\.dismiss) private var dismiss
    
    /// The tab animation name space.
    @Namespace var tabAnimation
    
    /// The profile view model.
    @StateObject var viewModel: ProfileViewModel
    
    /// The offset of the tab bar.
    @State var tabBarOffset: CGFloat = 0
    
    /// The offset of the title.
    @State var titleOffset: CGFloat = 0
    
    /// The current tab selected.
    @State var currentTab: HorizontalTab = .activity
    
    /// The header offset.
    @State var headerOffset: CGFloat = 0
    
    /// The activity height.
    @State private var activityHeight: Double = 0.0
    
    /// Init this view and creates a profile view model that sets the user id.
    /// - Parameter userID: The user id of the profile to show.
    init(userID: String) {
        self.userID = userID
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userID: userID))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loading
            } else {
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(spacing: 15) {
                        GeometryReader { proxy -> AnyView in
                            let minY = proxy.frame(in: .global).minY
                            DispatchQueue.main.async {
                                self.headerOffset = minY
                            }
                            return AnyView(
                                ZStack {
                                    BlurView()
                                        .opacity(blurViewOpacity())

                                    VStack(spacing: 5) {
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

                        profileHeader
                        tabsContent
                    }
                })
                .ignoresSafeArea(.all, edges: .top)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: NavBackButtonView(
                color: .primary,
                dismiss: self.dismiss
            )
        )
        .toolbar {
            if let user = viewModel.user {
                if user.isCurrentUser {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            // TODO: Refactor this
//                            SettingsView()
//                                .environmentObject(authVM)
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
    
    private var loading: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    // Display name
                    Rectangle()
                        .frame(width: 200, height: 25)
                        .cornerRadius(5)
                    
                    // Username
                    Rectangle()
                        .frame(width: 150, height: 20)
                        .cornerRadius(5)
                    
                    Spacer().frame(height: 10)
                    
                    // Followers & Following
                    HStack(spacing: 5) {
                        Rectangle()
                            .frame(width: 100, height: 20)
                            .cornerRadius(5)
                        
                        Rectangle()
                            .frame(width: 100, height: 20)
                            .cornerRadius(5)
                    }
                }
                
                Spacer()
                
                // Profile image
                Circle()
                    .frame(width: 100, height: 100)
            }
            
            Spacer().frame(height: 20)
            
            Rectangle()
                .frame(width: 250, height: 25)
                .cornerRadius(5)
            
            Divider()
            
            LoadingIndicator(
                animation: .circleTrim,
                color: .primary,
                speed: .fast
            )
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        }
        .redacted(reason: .placeholder)
        .shimmering()
        .opacity(0.5)
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private var lockedIndicator: some View {
        VStack {
            Image(systemName: "lock")
                .font(.system(size: 36))
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.primary)
            Spacer()
        }
    }
    
    private var profileTabs: some View {
        VStack(spacing: 0){
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    // Activity tab
                    TabButton(
                        title: HorizontalTab.activity.title,
                        tab: HorizontalTab.activity,
                        animation: tabAnimation,
                        currentTab: $currentTab
                    )
                    .frame(width: UIScreen.main.bounds.width / 2)
                    
                    // Last read tab
                    TabButton(
                        title: HorizontalTab.lastReads.title,
                        tab: HorizontalTab.lastReads,
                        animation: tabAnimation,
                        currentTab: $currentTab
                    )
                    .frame(width: UIScreen.main.bounds.width / 2)
                }
            }
            .padding(.top, 30)
        }
        .offset(y: tabBarOffset < 90 ? -tabBarOffset + 90 : 0)
        .overlay(
            GeometryReader { reader -> Color in
                let minY = reader.frame(in: .global).minY
                DispatchQueue.main.async {
                    self.tabBarOffset = minY
                }
                return Color.clear
            }
            .frame(width: 0, height: 0),
            alignment: .top
        )
        .background(Color("Background"))
        .zIndex(1)
    }
    
    @ViewBuilder
    private var profileHeader: some View {
        if let user = viewModel.user {
            VStack {
                ProfileHeaderView(user: user, viewModel: viewModel)
                    .overlay (
                        GeometryReader{ proxy -> Color in
                            let minY = proxy.frame(in: .global).minY
                            DispatchQueue.main.async {
                                self.titleOffset = minY
                            }
                            return Color.clear
                        }
                        .frame(width: 0, height: 0) ,alignment: .top)
                
                if !user.isCurrentUser && viewModel.followingStatus != .following {
                    lockedIndicator
                } else {
                    profileTabs
                }
            }
            .zIndex(-headerOffset > 80 ? 0 : 1)
        }
    }
    
    private var tabsContent: some View {
        VStack(spacing: 18){
            if currentTab == .activity {
                activities
            }

            if currentTab == .lastReads {
                // TODO: Refactor
                LastReadsView()
                    .environmentObject(viewModel)
            }
        }
        .padding(.top)
        .zIndex(0)
    }
    
    @ViewBuilder
    private var activities: some View {
        if !viewModel.activity.isEmpty {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.activity) { post in
                    FeedInstance(post: post)
                    Divider()
                    if let lastDocID = viewModel.activitiesLastDocument?.documentID as String? {
                        if post.documentID == lastDocID {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.primary)
                                    .onAppear {
                                        Task {
                                            await viewModel.fetchUserActivity()
                                        }
                                    }
                                Spacer()
                            }
                        }
                    }
                }
            }
        } else {
            HStack {
                Spacer()
                Text("No activity yet!")
                    .foregroundColor(.primary.opacity(0.7))
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
    
    // MARK: Profile Helper Functions.
    
    func getTitleTextOffset() -> CGFloat {
        let progress = 20 / titleOffset
        let offset = 60 * (progress > 0 && progress <= 1 ? progress : 1)
        return offset
    }
    
    func getOffset() -> CGFloat {
        let progress = (-headerOffset / 80) * 20
        return progress <= 20 ? progress : 20
    }
    
    func getScale() -> CGFloat {
        let progress = -headerOffset / 80
        let scale = 1.8 - (progress < 1.0 ? progress : 1)
        return scale < 1 ? scale : 1
    }
    
    func blurViewOpacity() -> Double {
        let progress = -(headerOffset + 80) / 150
        return Double(-headerOffset > 80 ? progress : 0)
    }
}

