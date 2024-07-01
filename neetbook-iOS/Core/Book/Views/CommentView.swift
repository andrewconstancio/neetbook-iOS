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
    @State private var showSheetDelete: Bool = false
    @State private var showSheetReport: Bool = false
    
    let bookId: String
    let currentUserId: String
    let comment: BookComment
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top) {
            Image(uiImage: comment.profilePicture)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Text(comment.displayName)
                        .font(.headline)
                        .foregroundColor(.primary.opacity(0.7))
                    
                    Text("\(dateFormatter.string(from: comment.dateCreated))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                
                Text(comment.comment ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
 
            Button {
                if currentUserId == comment.userId {
                    showSheetDelete = true
                } else {
                    showSheetReport = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.primary.opacity(0.7))
                    .rotationEffect(.degrees(90))
            }
            .padding(.top, 8)
        }
        .font(.system(size: 14))
        .popup(isPresented: $showSheetDelete) {
            VStack(spacing: 20) {
                if self.currentUserId == comment.userId {
                    deleteCommentButton
                }
                closeButtonDelete
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
        .popup(isPresented: $showSheetReport) {
            VStack(spacing: 20) {
                reportCommentButton
                closeButtonReport
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
        .padding(.top, 20)
//        .frame(maxWidth: .infinity, alignment: .top)
    }
}

extension CommentView {
    private var deleteCommentButton: some View {
        Button {
            Task {
                try? await bookViewModel.deleteBookComment(bookId: bookId, documentId: comment.documentId)
                showSheetDelete = false
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
    
    private var reportCommentButton: some View {
        Button {
            Task {
                try? await bookViewModel.reportComment(bookId: bookId,
                                                       commentDocID: comment.documentId,
                                                       comment: comment.comment ?? "")
                showSheetReport = false
            }
        } label: {
            HStack {
                Text("Report")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 300, height: 55)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.appColorOrange)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )

        }
    }
    
    private var closeButtonDelete: some View {
        Button {
            showSheetDelete = false
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
    
    private var closeButtonReport: some View {
        Button {
            showSheetReport = false
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
