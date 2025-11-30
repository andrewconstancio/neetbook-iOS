//
//  ProfileActivityView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/7/24.
//

import SwiftUI

//struct GeometrySizePreferenceKey: PreferenceKey {
//    static var defaultValue: CGSize = .zero
//    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
//        value = nextValue()
//    }
//}
//
//struct OnGeometrySizeChange: ViewModifier {
//    var action: (CGSize) -> Void
//    
//    init(perform action: @escaping (CGSize) -> Void) {
//        self.action = action
//    }
//    
//    func body(content: Content) -> some View {
//        content
//            .background {
//                GeometryReader { proxy in
//                    Color
//                        .clear
//                        .preference(key: GeometrySizePreferenceKey.self, value: proxy.size)
//                        .onPreferenceChange(GeometrySizePreferenceKey.self) { action($0) }
//                }
//            }
//    }
//}
//
//extension View {
//    func onGeometrySizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
//        modifier(OnGeometrySizeChange(perform: action))
//    }
//}

struct ProfileActivityView: View {
    
    /// The color environment color scheme. 
    @Environment(\.colorScheme) var colorScheme
    
    /// The profile view mode.
    @EnvironmentObject private var viewModel: ProfileViewModel
    
//    @Binding var activityHeight: Double
//    
//    @State private var childrenSize: CGSize = .init(width: CGFloat.infinity, height: CGFloat.infinity)
//    
    let userId: String
    
    var body: some View {
        GeometryReader { geo in
                if viewModel.activity.count > 0 {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.activity) { post in
                            PostView(
                                post: post,
                                viewModel: PostViewModel()
                            )
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
                    .padding(.bottom, 50)
                } else {
                    noActivity
                }
        }
    }
    
    private var noActivity: some View {
        HStack {
            Spacer()
            Text("No activity yet!")
                .foregroundColor(.primary.opacity(0.7))
                .fontWeight(.bold)
            Spacer()
        }
    }
}

//#Preview {
//    ProfileActivityView()
//}
