//
//  TestView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/6/24.
//

//import SwiftUI
//
//struct TestProfileView: View {
//    @StateObject private var viewModel = ProfileViewModel()
//    @Binding var showSignInView: Bool
//    @State var showProfileEditView: Bool = false
//    @State var showFollowListView: Bool = false
//    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
//    @State private var activityHeight: Double = 0.0
//    
//    let headerHeight: CGFloat = 300
//    let tabBarHeight: CGFloat = 50
//
//    static let tab1Height: CGFloat = 100
//    static let tab2Height: CGFloat = 800
//
//    @State var tabIndex = 0
//    @GestureState var dragOffset = CGSize.zero
//
//    var body: some View {
//
//        // The GeometryReader must contain the ScrollReader, not
//        // the other way around, otherwise scrolling doesn't work
//        GeometryReader { geometryProxy in
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    VStack(spacing: 0) {
//                        header.id(0)
//                        bottom(viewWidth: geometryProxy.size.width)
//                    }
//                }
//                // Scroll back to the header when the tab changes
//                .onChange(of: tabIndex) { newValue in
//                    withAnimation(.easeInOut(duration: 1)) {
//                        scrollViewProxy.scrollTo(0)
//                    }
//                }
//            }
//        }
//        .background(Color.white.ignoresSafeArea())
//        .task {
////            try? await viewModel.loadCurrentUser()
//            try? await viewModel.getPhotoURL()
////            try? await viewModel.getFavoriteBooks()
//            Utilities.shared.hideToolBarBackground()
//        }
//    }
//
//    private var header: some View {
//        ProfileHeaderView()
//            .environmentObject(viewModel)
//            .environmentObject(currentUserViewModel)
//            .frame(maxWidth: .infinity)
//            .frame(height: headerHeight)
//    }
//
//    private func bottom(viewWidth: CGFloat) -> some View {
//        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
//            Section {
//                pager(viewWidth: viewWidth)
//            } header: {
//                tabBar(viewWidth: viewWidth)
//            }
//        }
//    }
//
//    private func tabBar(viewWidth: CGFloat) -> some View {
//        HStack(spacing: 0) {
//            tab(title: "Activity", at: 0, viewWidth: viewWidth)
//                .opacity(tabIndex == 0 ? 1.0 : 0.3)
//            tab(title: "Favorites", at: 1, viewWidth: viewWidth)
//                .opacity(tabIndex == 1 ? 1.0 : 0.3)
//        }
//        .foregroundColor(.black)
//        .background(Color.white.ignoresSafeArea())
//        .bold()
//        .frame(maxWidth: .infinity)
//        .frame(height: tabBarHeight)
//    }
//
//    private func tab(title: String, at index: Int, viewWidth: CGFloat) -> some View {
//        Button {
//            withAnimation {
//                tabIndex = index
//            }
//        } label: {
//            Text(title)
//                .foregroundColor(.black)
//                .frame(width: viewWidth / 2)
//        }
//    }
//
//    func selectByDrag(viewWidth: CGFloat) -> some Gesture {
//        DragGesture()
//            .updating($dragOffset) { value, state, transaction in
//                let translation = value.translation
//
//                // Only interested in horizontal drag
//                if abs(translation.width) > abs(translation.height) {
//                    state = translation
//                }
//            }
//            .onEnded { value in
//                let translation = value.translation
//
//                // Switch view if the translation is more than a
//                // threshold (half the view width)
//                if abs(translation.width) > abs(translation.height) &&
//                    abs(translation.width) > viewWidth / 2 {
//                    tabIndex = translation.width > 0 ? 0 : 1
//                }
//            }
//    }
//
//    private func pager(viewWidth: CGFloat) -> some View {
//        HStack(alignment: .top, spacing: 0) {
////            ProfileActivityView(activityHeight: $activityHeight, userId: currentUserViewModel.userId)
////                .environmentObject(viewModel)
////                .frame(width: viewWidth, height: activityHeight + 50.0)
//
//            Text("Content 2")
//                .frame(width: viewWidth)
//                .background(Color.orange)
//        }
//        .fixedSize()
//        .offset(x: (CGFloat(-tabIndex) * viewWidth) + dragOffset.width)
//        .animation(.easeInOut, value: tabIndex)
//        .animation(.easeInOut, value: dragOffset)
//        .gesture(selectByDrag(viewWidth: viewWidth))
//    }
//}
