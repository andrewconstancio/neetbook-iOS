//
//  CommentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 12/1/23.
//

import SwiftUI
import PopupView

struct CommentView: View {
    @ObservedObject var bookViewModel: BookViewModel
    @State private var showSheet: Bool = false
    
    let bookId: String
    let currentUserId: String
    let comment: BookComment
    
    var body: some View {
        HStack {
            Image(uiImage: comment.profilePicture)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(radius: 20)
                .alignmentGuide(VerticalAlignment.center) {   // << here !!
                      $0[VerticalAlignment.top]
                  }
            
            VStack(alignment: .leading) {
                Text(comment.displayName)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.7))
                
                Text(comment.comment ?? "")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            Spacer()
            if currentUserId == comment.userId {
                Button {
                    showSheet = true
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black.opacity(0.7))
                        .rotationEffect(.degrees(90))
                }
            }
        }
        .popup(isPresented: $showSheet) {
            VStack(spacing: 20) {
                if self.currentUserId == comment.userId {
                    deleteCommentButton
                }
                closeButton
            }
            .foregroundColor(.white)
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(30, corners: [.topLeft, .topRight])

        } customize: {
            $0
                .isOpaque(true)
                .type(.toast)
                .dragToDismiss(true)
        }
        .alignmentGuide(VerticalAlignment.center) {   // << here !!
              $0[VerticalAlignment.top]
          }
        .padding(.top, 20)
    }
}

extension CommentView {
    private var deleteCommentButton: some View {
        Button {
            Task {
                try? await bookViewModel.deleteBookComment(bookId: bookId, documentId: comment.documentId)
                showSheet = false
            }
        } label: {
            HStack {
                Text("Delete")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 300, height: 55)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.appColorRed)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )

        }
    }
    
    private var closeButton: some View {
        Button {
            showSheet = false
        } label: {
            HStack {
                Text("Close")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .frame(width: 300, height: 55)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.white)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )

        }
    }
}

//struct CommentView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentView()
//    }
//}
