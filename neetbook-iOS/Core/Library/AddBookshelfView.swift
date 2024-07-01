//
//  AddBookshelfView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/8/24.
//

import SwiftUI

struct AddBookshelfView: View {
    
    @Binding var showNewBookshelfPopup: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var libraryViewModel: LibraryViewModel
    
    @StateObject private var viewModel = AddBookshelfViewModel()
    
    @State private var showImagePicker: Bool = false
    
    let bookshelf: Bookshelf?
    
    var body: some View {
        VStack() {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    if let bookshelf = bookshelf {
                        Text("Edit Bookshelf")
                            .bold()
                    } else {
                        Text("Add Bookshelf")
                            .bold()
                    }

                    Spacer()
                    
                    Button {
                        showNewBookshelfPopup = false
                    } label: {
                        Image(systemName: "x.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .bold()
                            .foregroundColor(.primary)
                            .offset(x: -10, y: 0)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Name")
                        .foregroundStyle(.secondary)
                    TextField("MyFavs...", text: $viewModel.name)
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Cover Photo (optional)")
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showImagePicker.toggle()
                    } label: {
                        if let image = viewModel.coverPhoto {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 70, height: 120)
                                    .cornerRadius(3)
                             }
                        } else {
                            ZStack {
                                 Image(systemName: "photo")
                                     .resizable()
                                     .frame(width: 20, height: 20)
                                     .foregroundColor(.primary)
                                 
                                 Rectangle()
                                     .stroke(style: StrokeStyle(lineWidth: 2, dash: [3]))
                                     .foregroundColor(colorScheme == .dark ? .white : .black)
                                     .frame(width: 70, height: 120)
                                     .cornerRadius(3)
                             }
                        }
                    }
                }
                .padding(.bottom, 10)
                
                Toggle(isOn: $viewModel.isPublic) {
                    Text("Public")
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 50)
                
                Button {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    Task {
                        if let bookshelf = bookshelf {
                            try? await viewModel.editBookshelf(bookshelf: bookshelf)
                        } else {
                            try? await viewModel.saveBookshelf()
                            try? await libraryViewModel.getBookshelves()
                        }
                    }
                    showNewBookshelfPopup = false
                } label: {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 60)
                        .background(Color.appColorOrange)
                        .cornerRadius(50)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $viewModel.coverPhoto)
        }
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? .black : .white)
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .onAppear {
            if let bookshelf = bookshelf {
                Task {
                    try? await viewModel.initBookshelf(bookshelf: bookshelf)
                }
            }
        }
    }
}

//#Preview {
//    AddBookshelfView(showNewBookshelfPopup: .constant(true))
//}
