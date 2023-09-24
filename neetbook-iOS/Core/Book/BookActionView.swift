//
//  BookActionView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/5/23.
//

import SwiftUI
import Combine

struct BookActionView: View {
    @ObservedObject var viewModel: BookViewModel
    @Binding var showBookActionSheet: Bool
    @State var actionSelected: ReadingActions?
    @State private var currentPage: String = "0"
    @Environment(\.colorScheme) var colorScheme
    
    let book: Book
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        ZStack {
//            Color.appColorPale
//                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                // title
                titleText
                Spacer()
                // reading button
                readingButton
                // page count input
//                if actionSelected == .reading {
//                    pageCountInput
//                }--
                // want to read button
                wantToReadButton
                // read button
                readButton
                Spacer()
                // save button
                saveButton
            }
            .padding()
        }
    }
}

extension BookActionView {
    private var titleText: some View {
        Text("So you like this book?")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(colorScheme == .dark ? Color.appColorBeige : Color.black)
    }
    
    private var readingButton: some View {
        Button {
            if viewModel.userActions == .reading {
                viewModel.userActions = .removeAction
            } else {
                viewModel.userActions = .reading
            }
        } label: {
            HStack {
                Image(systemName: "book.fill")
                    .offset(x: 10)
                Text("Reading")
                    .offset(x: 10)
                Spacer()
                if viewModel.userActions == .reading {
                    Image(systemName: "checkmark")
                        .offset(x: -20)
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(viewModel.userActions == .reading ? Color.appColorYellow : .white)
            .cornerRadius(10)
        }
    }
    
    private var pageCountInput: some View {
        VStack {
            Text("Put your current page if you want to!")
                .foregroundColor(Color.appColorGreen)
            Text("Page total: \(book.pageCount)")
                .foregroundColor(.black)
            
            TextField("", value: $currentPage, formatter: formatter)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .keyboardType(.numberPad)
                .onReceive(Just(currentPage)) { newValue in
                      let filtered = newValue.filter { "0123456789".contains($0) }
                      if filtered != newValue {
                          self.currentPage = filtered
                      }
                }
        }
        .padding()
    }
    
    private var wantToReadButton: some View {
        Button {
            if viewModel.userActions == .wantToRead {
                viewModel.userActions = .removeAction
            } else {
                viewModel.userActions = .wantToRead
            }
        } label: {
            HStack {
                Image(systemName: "heart.fill")
                    .offset(x: 10)
                Text("Want to read")
                    .offset(x: 10)
                Spacer()
                if viewModel.userActions == .wantToRead {
                    Image(systemName: "checkmark")
                        .offset(x: -20)
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(viewModel.userActions == .wantToRead ? Color.appColorYellow : .white)
            .cornerRadius(10)
        }
    }
    
    private var readButton: some View {
        Button {
            if viewModel.userActions == .read {
                viewModel.userActions = .removeAction
            } else {
                viewModel.userActions = .read
            }
        } label: {
            HStack {
                Image(systemName: "book.closed.fill")
                    .offset(x: 10)
                Text("Read")
                    .offset(x: 10)
                Spacer()
                if viewModel.userActions == .read {
                    Image(systemName: "checkmark")
                        .offset(x: -20)
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(viewModel.userActions == .read ? Color.appColorYellow : .white)
            .cornerRadius(10)
        }
    }
    
    private var saveButton: some View {
        Button {
            guard let action = viewModel.userActions else { return }
            Task {
                try? await viewModel.saveUserBookAction(bookId: book.bookId, action: action)
            }
            showBookActionSheet = false
        } label: {
            Text("Save")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(.blue)
                .cornerRadius(20)
        }
    }
}

struct BookActionView_Previews: PreviewProvider {
    static var previews: some View {
        BookActionView(viewModel: BookViewModel(), showBookActionSheet: .constant(true), book: Book(bookId: "123", title: "123", author: "123", coverURL: "123", description: "123", pageCount: 2, categories: ["123"]))
    }
}
