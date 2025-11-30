//
//  CommentViewNew.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//
import SwiftUI

struct CommentViewNew: View {
    
    /// The book id fo comments.
    let bookId: String
    
    /// The comment.
    let comment: BookComment
    
    /// User id of the current user.
    let currentUserId: String
    
    /// The book view model.
    @ObservedObject var bookVM: BookViewModelNew
    
    /// Flag to show the delete comment pop up.
    @State var showSheetDelete = false
    
    /// Flag to show the report comment pop up.
    @State private var showSheetReport = false
    
    var body: some View {
        HStack(alignment: .top) {
            userInformationAndComment
            Spacer()
            commentActionButton
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
    }
    
    
    /// Show the users profile picture, display name, comment date and comment.
    @ViewBuilder
    private var userInformationAndComment: some View {
        Image(uiImage: comment.profilePicture)
            .resizable()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
        
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                Text(comment.displayName)
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.7))
                
                Text("\(comment.dateCreated.formatted())")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.comment ?? "")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
    
    /// Shows either the delete or report action button on the comment.
    private var commentActionButton: some View {
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
    
    /// The delete comment button.
    private var deleteCommentButton: some View {
        Button {
            Task {
                await bookVM.deleteComment(
                    id: bookId,
                    documentId: comment.documentId
                )
                showSheetDelete = false
            }
        } label: {
            HStack {
                Text("Delete")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .modifier(CommentActionButtonModifier(backgroundColor: .appColorRed))
        }
    }
    
    /// The report comment button.
    private var reportCommentButton: some View {
        Button {
            Task {
                await bookVM.reportComment(
                    id: bookId,
                    documentId: comment.documentId,
                    comment: comment.comment ?? ""
                )
                showSheetReport = false
            }
        } label: {
            HStack {
                Text("Report")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .modifier(CommentActionButtonModifier(backgroundColor: .appColorOrange))
        }
    }
    
    /// The close report comment button.
    private var closeButtonReport: some View {
        Button {
            showSheetReport = false
        } label: {
            HStack {
                Text("Close")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .modifier(CommentActionButtonModifier(backgroundColor: .white))
        }
    }
    
    /// The close delete comment button.
    private var closeButtonDelete: some View {
        Button {
            showSheetDelete = false
        } label: {
            HStack {
                Text("Close")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .modifier(CommentActionButtonModifier(backgroundColor: .white))
        }
    }
}

