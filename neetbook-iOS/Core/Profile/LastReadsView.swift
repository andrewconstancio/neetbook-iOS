//
//  LastReadsView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 6/30/24.
//

import SwiftUI

struct LastReadsView: View {
    
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd/yyyy"
        return formatter
    }()
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(viewModel.finishedBooks) { book in
                NavigationLink {
                    BookView(book: book.book)
                } label: {
                    HStack {
                        if let coverPhoto = book.book.coverPhoto{
                            Image(uiImage: coverPhoto)
                                .resizable()
                                .frame(width: 80, height: 120)
                                .cornerRadius(5)
                        }
                        VStack(alignment: .leading) {
                            Text(book.book.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Text(book.book.author)
                                .font(.subheadline)
                                .foregroundColor(.primary.opacity(0.5))
                                .multilineTextAlignment(.leading)
                            
                            HStack {
                                Image(systemName: "doc.plaintext")
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(book.book.pages)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary.opacity(0.5))
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.leading, 4)
                            HStack {
                                Image(systemName: "calendar")
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(dateFormatter.string(from: book.dateAdded))")
                                    .font(.subheadline)
                                    .foregroundColor(.primary.opacity(0.5))
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 2)
                            }
                            .padding(.leading, 4)
                            
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                }
            }
        }
        .onAppear {
            Task {
                try? await viewModel.getFinishedBooks()
            }
        }
    }
}

#Preview {
    LastReadsView()
}
