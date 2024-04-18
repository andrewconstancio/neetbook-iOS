//
//  AddToFavoritesView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/3/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct AddToFavoritesView: View {
    let book: Book
    @StateObject private var viewModel = AddToFavoritesViewModel()
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Favorites List")
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            if viewModel.isLoadingMainData {
                VStack {
                    Spacer()
                    LoadingIndicator(animation: .threeBalls, color: .black, speed: .fast)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                Spacer()
                List {
                    ForEach(viewModel.books) { fav in
                        HStack {
                            Text("\(fav.row)")
                                .foregroundColor(.black)
                                .bold()
                            AsyncImage(url: URL(string: fav.book.coverURL)) { image in
                                image
                                    .resizable()
                                    .frame(width: 70, height: 100)
                                    .shadow(radius: 10)
                                
                            } placeholder: {
                                ProgressView()
                            }
                            
                            VStack(alignment: .leading) {
                                Text(fav.book.title)
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Text(fav.book.author)
                                    .font(.system(size: 14))
                                    .fontWeight(.bold)
                                    .foregroundColor(.black.opacity(0.7))
                            }
                        }
                        .listRowBackground(fav.newBook ? Color.green.opacity(0.8) : .white)
                    }
                    .onDelete { indexSet in
                        delete(indexSet: indexSet)
                    }
                    .onMove { indexSet, newOffset in
                            move(indexSet: indexSet, newOffset: newOffset)
                        }
                    }
                    .navigationBarItems(trailing: EditButton())
                    .scrollContentBackground(.hidden)
                
                    Spacer()
                    if isEditing {
                        Button {
                            Task {
                                try? await viewModel.saveFavoriteBooks()
                            }
                        } label: {
                            Text("Save")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(.blue)
                                .cornerRadius(20)
                                .padding()
                        }
                    }
                    Spacer()
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .primary, dismiss: self.dismiss))
        .onAppear {
            Task {
                try? await viewModel.getFavoriteBooks(toSaveBook: book)
                try? await viewModel.saveFavoriteBooks()
            }
        }
    }
    
    func move(indexSet: IndexSet, newOffset: Int) {
        viewModel.books.move(fromOffsets: indexSet, toOffset: newOffset)
        
        for i in 0..<viewModel.books.count {
            viewModel.books[i].setRowNumber(num: i+1)
        }
        
        Task {
            try? await viewModel.saveFavoriteBooks()
        }
    }
    
    func delete(indexSet: IndexSet) {
        viewModel.books.remove(atOffsets: indexSet)
        
        for i in 0..<viewModel.books.count {
            viewModel.books[i].setRowNumber(num: i+1)
        }
        
        Task {
            try? await viewModel.saveFavoriteBooks()
        }
    }
}

//struct AddToFavoritesView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddToFavoritesView()
//    }
//}
