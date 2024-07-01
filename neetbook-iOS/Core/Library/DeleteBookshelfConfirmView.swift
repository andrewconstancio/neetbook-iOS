//
//  DeleteBookshelfConfirmView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 5/27/24.
//

import SwiftUI


struct DeleteBookshelfConfirmView: View {
    @Binding var showDeleteBookshelfConfirm: Bool
//    var bookshelf: Bookshelf
    var deleteBookshelf: () async throws -> ()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading) {
                        Text("Are you sure?")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)
                        Text("This action cannot be undone.")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.black.opacity(0.5))
                    }
                    VStack(alignment: .leading) {
                        Button {
                            Task {
//                                try? await viewModel.deleteBookshelf(bookshelf: bookshelf)
                                try? await deleteBookshelf()
                                showDeleteBookshelfConfirm = false
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            HStack {
                                Text("Delete")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 300, height: 35)
                            .font(.system(size: 14))
                            .padding(10)
                            .background(Color.appColorRed)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.clear, lineWidth: 1)
                            )
                        }
                        
                        Button {
                            showDeleteBookshelfConfirm = false
                        } label: {
                            HStack {
                                Text("Close")
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                            .frame(width: 300, height: 35)
                            .font(.system(size: 14))
                            .padding(10)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
        .padding(.horizontal, 40)
    }
}
