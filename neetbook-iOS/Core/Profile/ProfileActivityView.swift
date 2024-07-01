//
//  ProfileActivityView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/7/24.
//

import SwiftUI

struct GeometrySizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct OnGeometrySizeChange: ViewModifier {
    var action: (CGSize) -> Void
    
    init(perform action: @escaping (CGSize) -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color
                        .clear
                        .preference(key: GeometrySizePreferenceKey.self, value: proxy.size)
                        .onPreferenceChange(GeometrySizePreferenceKey.self) { action($0) }
                }
            }
    }
}

extension View {
    func onGeometrySizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(OnGeometrySizeChange(perform: action))
    }
}

struct ProfileActivityView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var userStateViewModel: UserStateViewModel
    
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    @Binding var activityHeight: Double
    
    @State private var childrenSize: CGSize = .init(width: CGFloat.infinity, height: CGFloat.infinity)
    
    let userId: String
    
    var body: some View {
        GeometryReader { geo in
                if viewModel.activity.count > 0 {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.activity) { post in
                        PostInstanceView(post: post, linkToPost: true)
                            .environmentObject(userStateViewModel)
                            .onGeometrySizeChange { childrenSize = $0 }
                        
                        Divider()
                        if let lastDocID = viewModel.activitiesLastDocument?.documentID as String? {
                            if post.documentID == lastDocID {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .tint(.primary)
                                        .onAppear {
                                            Task {
                                                try await viewModel.getUserActivity(userId: userId)
                                                activityHeight = (childrenSize.height * Double(viewModel.activity.count)) + 100
                                            }
                                        }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
                .onAppear {
                    activityHeight = (childrenSize.height * Double(viewModel.activity.count)) + 100
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
    }
}

//#Preview {
//    ProfileActivityView()
//}
