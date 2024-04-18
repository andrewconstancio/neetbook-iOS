//
//  PostCommentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/18/24.
//

import SwiftUI

struct PostCommentView: View {
    let comment: PostComment
    
    let currentUserId: String
    
    @EnvironmentObject private var viewModel: PostViewModel
    
    @State private var showSheetDelete: Bool = false
    
    @State private var showSheetReport: Bool = false
    
    
    var body: some View {
        HStack(alignment: .top) {
            Image(uiImage: comment.profilePicture)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(comment.displayName)
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.7))
                
                Text(comment.comment ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(comment.dateCreated.timeAgoDisplay())
                    .fontWeight(.light)
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.primary.opacity(0.5))
            }
            Spacer()
            if currentUserId == comment.userId {
                Button {
                    showSheetDelete = true
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black.opacity(0.7))
                        .rotationEffect(.degrees(90))
                        .padding(.top, 10)
                }
            } else {
                Button {
                    showSheetReport = true
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary.opacity(0.7))
                        .rotationEffect(.degrees(90))
                        .padding(.top, 10)
                }
            }
        }
        .padding()
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
    }
}

extension PostCommentView {
    private var deleteCommentButton: some View {
        Button {
            Task {
                try? await viewModel.deleteComment(documentId: comment.documentId)
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
                try? await viewModel.reportComment(commentDocID: comment.documentId,
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

#Preview {
    PostCommentView(comment: DeveloperPreview.instance.postComment, currentUserId: "9iNv2tf5tqQMFvdwhLPLzDo2OZf1")
}
