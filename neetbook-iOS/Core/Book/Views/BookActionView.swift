//
//  BookActionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/5/23.
//

import SwiftUI
import Combine
import PopupView

struct BookshelfButton: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let bookshelfAddedId: String
    @ObservedObject var viewModel: BookViewModel
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .bold()
                .foregroundStyle(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(viewModel.bookshelvesAdded.contains(bookshelfAddedId) ? Color.appColorPurple : .clear)
                .cornerRadius(10)
        } else {
            content
                .bold()
                .foregroundStyle(viewModel.bookshelvesAdded.contains(bookshelfAddedId) ? .white : .black)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(viewModel.bookshelvesAdded.contains(bookshelfAddedId) ? Color.appColorPurple : .white)
                .cornerRadius(10)
        }
    }
}

struct BookActionView: View {
    @ObservedObject var viewModel: BookViewModel
    @Binding var showBookActionSheet: Bool
    @State var actionSelected: ReadingActions?
    @State private var currentPage: String = "0"
    @State private var showFavoritesView: Bool = false
    @State var showNewBookshelfPopup: Bool = false
    let book: Book
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            titleText
            Spacer()
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<viewModel.userBookshelves.count, id: \.self) { index in
                        HStack {
                            Spacer()
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                if viewModel.bookshelvesAdded.contains(viewModel.userBookshelves[index].id) {
                                    print("before: ", viewModel.bookshelvesAdded)
                                    if let foundIndex = viewModel.bookshelvesAdded.firstIndex(of: viewModel.userBookshelves[index].id) {
                                        viewModel.bookshelvesAdded.remove(at: foundIndex)
                                        print("after: ", viewModel.bookshelvesAdded)
                                    }
                                } else {
                                    viewModel.bookshelvesAdded.append(viewModel.userBookshelves[index].id)
                                }
                            } label: {
                                HStack {
                                    if viewModel.userBookshelves[index].imageUrl == "" {
                                        NoPhotoBookshelfView(width: 20, height: 20)
                                            .shadow(radius: 10)
                                    } else {
                                        AsyncImage(url: URL(string: viewModel.userBookshelves[index].imageUrl)) { image in
                                            image
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .scaledToFit()
                                                .clipShape(Circle())
                                            
                                        } placeholder: {
                                        }
                                    }
                                    Text("\(viewModel.userBookshelves[index].name)")
                                        .offset(x: 10)
                                        .bold()
                                    
                                    Spacer()
                                    if viewModel.bookshelvesAdded.contains(viewModel.userBookshelves[index].id) {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .offset(x: -20)
                                    }
                                }
                                .modifier(BookshelfButton(bookshelfAddedId: viewModel.userBookshelves[index].id, viewModel: viewModel))
                            }
                            Spacer()
                        }
                    }
                }
            }
            HStack {
                Spacer()
                saveButton
                Spacer()
            }
        }
        .padding(5)
    }
}

extension BookActionView {
    private var titleText: some View {
        Text("Add to bookshelf")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .padding()
    }
    
    private var saveButton: some View {
        Button {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            Task {
                do {
                    try await viewModel.saveToBookshelves(bookId: book.bookId)
                } catch {
                    print(error.localizedDescription)
                }
            }
            showBookActionSheet = false
        } label: {
            Text("Save")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 300, height: 60)
                .background(Color.appColorOrange)
                .cornerRadius(10)
        }
    }
}

//struct BookActionView_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        @StateObject  var vm = BookViewModel(bookId: "123")
//        BookActionView(viewModel: vm, showBookActionSheet: .constant(true), book: Book(bookId: "123", title: "123", author: "123", coverURL: "123", description: "123", publishedYear: "123"))
//    }
//}
