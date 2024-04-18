//
//  AuthenticationView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//


import SwiftUI
import Firebase
import AuthenticationServices

struct AuthenticationView: View {
    
    @State private var showingSheet = false
    
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()
            VStack {
                Text("neetbook.")
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                
                Image("landingPage")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .scaledToFit()
                    .padding(.bottom, 100)
                
                // Google sign in button
                googleSignInButton
                
                // Apple sign in button
                appleSignInButton
                
                Text("By Signing in you agree to our [Terms Of Service](https://sites.google.com/view/neetbookios/terms-of-service?authuser=0)\n and the [Guidelines](https://sites.google.com/view/neetbookios/guidelines?authuser=0)")
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .font(.system(size: 12))
                    
            }
            .padding()
        }
    }
}

extension AuthenticationView {
    /// Google sign in button view
    private var googleSignInButton: some View {
        Button(action: {
            Task {
                do {
                    let accountMade = try await viewModel.signInUserFlow(signInMethod: .google)
                    print(accountMade)
                } catch {
                    print(error)
                }
            }
        }, label: {
            HStack {
                Image("google")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                
                Text("Sign in with Google")
                    .font(.title3)
                    .fontWeight(.medium)
                    .kerning(1.1)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(20)
        })
    }
    
    /// Apple sign in button view
    private var appleSignInButton: some View {
        Button{
            Task {
                do {
                    let accountMade = try await viewModel.signInUserFlow(signInMethod: .apple)
                    print(accountMade)
                } catch {
                    print("error: ", error)
                }
            }
        } label: {
            SignInWithAppleButtonViewRepresentable(type: .default, style: .white)
                .allowsHitTesting(false)
        }
        .frame(height: 55)
        .cornerRadius(20)
        .onChange(of: viewModel.didSignInWithApple) { newValue in
            if newValue == true {
                print("Signed in with apple")
            }
        }
    }
}


