//
//  SearchBarView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isEditing: Bool
    var searchFunction: () async throws -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    searchText.isEmpty ?
                    Color.black.opacity(0.3) : Color.black
                )
            
            TextField("", text: $searchText, onEditingChanged: { editing in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isEditing = editing
                }
            })
            .placeholder(when: searchText.isEmpty) {
                Text("Search...")
                    .foregroundColor(.gray)
            }
            .onSubmit {
                Task {
                    try? await self.searchFunction()
                }
            }
            .submitLabel(.search)
            .disableAutocorrection(true)
            .overlay (
                Image(systemName: "xmark.circle.fill")
                    .padding()
                    .offset(x: 10)
                    .foregroundColor(.black)
                    .opacity(searchText.isEmpty ? 0.0 : 1.0)
                    .onTapGesture {
                        searchText = ""
                        hideKeyboard()
                    }
                ,alignment: .trailing
            )
            
            .foregroundColor(.black)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 0)
        )
//        .padding()
    }
}
