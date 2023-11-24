//
//  DisplayAndUsernameSetupView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/21/23.
//

import SwiftUI
import Combine

struct UserNameSetupView: View {
    @ObservedObject var viewModel: ProfileSetupViewRootViewModel
    @State private var shouldShowImagePicker = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("What do you want to be known as?")
                .font(.title3)
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            VStack {
                TextField("", text: $viewModel.displayname.max(30))
                    .placeholder(when: viewModel.displayname.isEmpty) {
                        Text("Display name...")
                            .foregroundColor(Color.black.opacity(0.3))
                    }
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .frame(height: 55)
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(20)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .onChange(of: viewModel.displayname) { _ in
                        viewModel.checkUsernameFormComplete()
                    }
                    .onReceive(Just(viewModel.displayname)) { newValue in
                        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-"
                        let filtered = newValue.filter { allowedCharacters.contains($0) }
                        if filtered != newValue {
                            self.viewModel.displayname = filtered
                        }
                    }
                
                Text("Please enter a display name. This can be changed anytime.")
                    .foregroundColor(.white.opacity(0.3))
                    .font(.system(size: 12))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }

            VStack {
                HStack {
                    TextField("", text: $viewModel.username.max(20))
                        .placeholder(when: viewModel.username.isEmpty) {
                            Text("Username...")
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .frame(height: 55)
                        .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                        .frame(maxWidth: .infinity)
                        .fontWeight(.bold)
                        .background(Color.clear)
                        .foregroundColor(viewModel.validUsername ? .green : .white)
                        .cornerRadius(20)
                        .onReceive(Just(viewModel.username)) { newValue in
                            let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-"
                            let filtered = newValue.filter { allowedCharacters.contains($0) }
                            if filtered != newValue {
                                self.viewModel.username = filtered
                            }
                        }
                    
                    
                    if viewModel.hashcode != "" {
                        Text("#\(viewModel.hashcode)")
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.validUsername ? .green : .white)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                
                Text("Enter a username. Be creative!")
                
                    .foregroundColor(.white.opacity(0.3))
                    .font(.system(size: 12))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            Spacer()
            Button {
                hideKeyboard()
                withAnimation(.spring()) {
                    viewModel.setProgressIndexStep += 1
                 }
            } label: {
                Text("Next")
            }
            .buttonStyle(NextButton(isValid: viewModel.validUsernameAndDisplayName))
            .disabled(!viewModel.validUsernameAndDisplayName)
        }
    }
}
