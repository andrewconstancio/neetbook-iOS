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
                VStack(alignment: .leading){
                    ForEach(0..<viewModel.activity.count, id: \.self) { index in
                        NavigationLink {
                            PostView(post: viewModel.activity[index])
                                .environmentObject(userStateViewModel)
                        } label: {
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                            
                                        Text(viewModel.activity[index].title)
                                            .foregroundColor(.primary)
                                            .font(.system(size: 14))
                                        
                                        Text(viewModel.activity[index].book.title)
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                            .font(.system(size: 14))
                                        
                                        Text("by \(viewModel.activity[index].book.author)")
                                            .foregroundColor(.primary)
                                            .font(.system(size: 14))
                                        
//                                        Spacer()
                                        Text(viewModel.activity[index].dateEvent.timeAgoDisplay())
                                            .fontWeight(.light)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary.opacity(0.5))
                                            .font(.system(size: 14))
                                    }
                                    Spacer()
                                    NavigationLink {
                                        BookView(book: viewModel.activity[index].book)
                                    } label: {
                                        if let image = viewModel.activity[index].book.coverPhoto {
                                            Image(uiImage: image)
                                                .resizable()
                                                .frame(width: 65, height: 100)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(5)
                            }
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? .indigo.opacity(0.4) : .white)
                            .clipShape(RoundedRectangle(cornerRadius:10))
                            .shadow(radius: 3)
                        }
                    }
                    .onGeometrySizeChange { childrenSize = $0 }
                }
                .onAppear {
                    activityHeight = childrenSize.height * Double(viewModel.activity.count)
                }
                } else {
                    HStack {
                        Spacer()
                        Text("No activity yet!")
                            .foregroundColor(.primary.opacity(0.7))
                            .fontWeight(.bold)
                        Spacer()
                    }
//                    VStack {
//                        Text("No activity yet!")
//                            .foregroundColor(.black.opacity(0.7))
//                            .fontWeight(.bold)
//                        Spacer()
//                        Spacer()
//                        Spacer()
//                    }
                }
        }
    }
}

//#Preview {
//    ProfileActivityView()
//}
