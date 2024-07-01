//
//  MarkBookView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 5/29/24.
//

import SwiftUI

struct MarkBookLabel: ViewModifier {
    @Binding var markSelected: String
    let markType: String

    func body(content: Content) -> some View {
        content
            .bold()
            .frame(height: 30)
            .foregroundStyle(markSelected == markType ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(markSelected == markType ? .green : .white)
            .cornerRadius(10)
    }
}

fileprivate struct SelectableButton: View {
    @Binding var markSelected: String
    let markType: String
    let text: String

    var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .soft)
            impactMed.impactOccurred()
            if markSelected == "" || markSelected != markType {
                markSelected = markType
            } else {
                markSelected = ""
            }
        }) {
            HStack {
                Text(text)
                    .offset(x: 10)
                    .bold()
                Spacer()
            }
            .modifier(MarkBookLabel(markSelected: $markSelected, markType: markType))
        }
    }
}

struct MarkBookView: View {
    
    @ObservedObject var viewModel: BookViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showBookMarkSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SelectableButton(markSelected: $viewModel.markSelected, markType: "reading", text: "Reading")

             SelectableButton(markSelected: $viewModel.markSelected, markType: "want to read", text: "Want To Read")

             SelectableButton(markSelected: $viewModel.markSelected, markType: "finished", text: "Finished")
             .padding(.bottom, 50)

            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
                
                Task {
                    try? await viewModel.saveRemoveToMarkedBooks()
                }
                
                showBookMarkSheet = false
            } label: {
                HStack {
                    Spacer()
                    Text("Save")
                        .bold()
                    Spacer()
                }
                .bold()
                .frame(height: 30)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appColorOrange)
                .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.7))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
}

//#Preview {
//    MarkBookView()
//}
