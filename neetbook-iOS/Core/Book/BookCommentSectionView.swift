//
//  BookCommentSectionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import SwiftUI
import SwiftfulLoadingIndicators
import Combine


struct BookCommentSectionView: View {
    @ObservedObject var viewModel: BookViewModel
    @Environment(\.dismiss) private var dismiss
    let book: Book
    @State private var height: CGFloat = 30
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.isLoadingComments {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LoadingIndicator(animation: .circleTrim, color: .primary, speed: .fast)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                VStack(alignment: .leading) {
                    if(viewModel.bookComments.count > 0) {
                        ScrollView {
                            ForEach(0..<viewModel.bookComments.count, id: \.self) { index in
                                CommentView(bookViewModel: viewModel, bookId: book.bookId, currentUserId: viewModel.currentUserId, comment: viewModel.bookComments[index])
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                    Spacer()
                    HStack {
//                        if let profilePhoto = viewModel.currentUser?.profilePhoto {
//                            Image(uiImage: profilePhoto)
//                                .resizable()
//                                .frame(width: 40, height: 40)
//                                .shadow(radius: 10)
//                                .cornerRadius(10)
//                                .clipShape(Circle())
//                        }
                        if let photoURL = viewModel.currentUser?.photoUrl {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .shadow(radius: 10)
                                    .cornerRadius(10)
                                    .clipShape(Circle())

                            } placeholder: {
                                ProgressView()
                            }
                        }

                        ResizableTF(text: $viewModel.userNewComment, height: $height)
                            .frame(height: height)
                            .padding(.horizontal)
                            .background(.white)
                            .cornerRadius(15)
                        
                        Button {
                            Task {
                                try? await viewModel.addUserBookComment(bookId: book.bookId)
                                hideKeyboard()
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(Color.appColorPurple)
                                .frame(width: 10, height: 10)
                                .padding(5)
                        }
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
//        .onAppear {
//            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { (data) in
//                let height1 = data.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
//                self.keyboardHeight = height1.cgRectValue.height
//            }
//            
//            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { (_) in
//                self.keyboardHeight = 0
//            }
//        }
        .navigationBarBackButtonHidden(true)
        .padding(10)
        .task {
            try? await viewModel.getAllBookComments(bookId: book.bookId)
        }
        .background(Color("Background"))
    }
}

//struct BookCommentSectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookCommentSectionView(viewModel: BookViewModel(), bookId: "asdfasdf")
//    }
//}
