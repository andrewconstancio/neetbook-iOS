//
//  BookCommentSectionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/16/23.
//

import SwiftUI
import SwiftfulLoadingIndicators
import Combine


struct ResizableTF: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    func makeCoordinator() -> Coordinator {
        return ResizableTF.Coordinator(parent1: self)
    }
    
    func makeUIView(context: Context) -> some UITextView {
        let view = UITextView()
        view.isEditable = true
        view.isScrollEnabled = true
        view.text = "Enter Comment"
        view.textColor = .gray
        view.backgroundColor = .white
        view.delegate = context.coordinator
        view.font = UIFont(name: "SF Pro", size: 26)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            self.height = uiView.contentSize.height < 30.0 ? 30.0 : uiView.contentSize.height
        }
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: ResizableTF
        
        init(parent1: ResizableTF) {
            self.parent = parent1
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = .black
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
                self.parent.text = textView.text
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if self.parent.text == "" {
                textView.text = ""
                textView.textColor = .black
            }
        }
    }
}

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
                        LoadingIndicator(animation: .threeBallsRotation, color: .black, speed: .fast)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(book.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text("(\(book.publishedYear))")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        Text("\(book.author)")
                            .foregroundColor(.black.opacity(0.7))
                    }
                

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
                            Text("Post")
                                .foregroundColor(Color.appColorPurple)
                                .bold()
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
        .navigationBarItems(leading: NavBackButtonView(color: .black, dismiss: self.dismiss))
        .padding(10)
        .task {
            try? await viewModel.getAllBookComments(bookId: book.bookId)
        }
        .background(Color.white.ignoresSafeArea(.all))
    }
}

//struct BookCommentSectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookCommentSectionView(viewModel: BookViewModel(), bookId: "asdfasdf")
//    }
//}
