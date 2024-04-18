//
//  EditBookSelectionPopupView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/14/24.
//

import SwiftUI

struct EditBookSelectionPopupView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showEditBookshelfPopup: Bool
    @Binding var showEditBookshelf: Bool
    @Binding var showDeleteBookshelfConfirm: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Button {
                showEditBookshelfPopup = true
                showEditBookshelf = false
            } label: {
                HStack {
                    Image(systemName: "pencil")
                        .frame(width: 30, height: 20)
                    
                    Text("Edit")
                        .bold()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }

            Button {
                showDeleteBookshelfConfirm = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .frame(width: 30, height: 20)
                    Text("Delete")
                        .bold()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? .black.opacity(0.7) : .white)
        .cornerRadius(10, corners: [.topLeft, .topRight])
    }
}
