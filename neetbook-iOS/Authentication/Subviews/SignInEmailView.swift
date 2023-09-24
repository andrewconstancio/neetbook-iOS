//
//  SignInEmailView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        let returnedUserData = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        print(returnedUserData)
    }
    
    func signIn () async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
        print(returnedUserData)
    }
}

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    
    var body: some View {
        
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()
            VStack {
                Text("neetbook.")
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .foregroundColor(.white)
//                    .fontWeight(.bold)
                    .font(.title)
                
                Text("Enter your email to sign up or log in:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
//                    .padding(.horizontal)
//                    .fontWeight(.bold)
                    .font(.title3)
                    .padding(.top)
                
                TextField("Email...", text: $viewModel.email)
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                
                SecureField("Password...", text: $viewModel.password )
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                
                Button {
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                            return
                        } catch {
                            print(error)
                        }
                        
                        do {
                            try await viewModel.signIn()
                            showSignInView = false
                            return
                        } catch {
                            print(error)
                        }

                    }
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity )
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInEmailView(showSignInView: .constant(false))
    }
}
