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
            Color.systemBackground
                .ignoresSafeArea()
            VStack {
                Text("neetbook.")
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
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
                
                Text(makeAttributedText())
                   .padding(.top, 10)
                   .font(.system(size: 12))
                
//                Text("By Signing in you agree to our [Terms Of Service](https://sites.google.com/view/neetbookios/terms-of-service?authuser=0)\n and the [Guidelines](https://sites.google.com/view/neetbookios/guidelines?authuser=0)")
//                    .foregroundColor(Color.systemIndigo)
//                    .padding(.top, 10)
//                    .font(.system(size: 12))
                    
            }
            .padding()
        }
    }
    
    func makeAttributedText() -> AttributedString {
        var attributedString = try! AttributedString(markdown:
            "By signing in you agree to our [Terms Of Service](https://sites.google.com/view/neetbookios/terms-of-service?authuser=0)\n and the [Guidelines](https://sites.google.com/view/neetbookios/guidelines?authuser=0)"
        )

        for run in attributedString.runs {
            if let _ = run.link {
                attributedString[run.range].foregroundColor = .init(uiColor: .systemIndigo)
            }
        }
        return attributedString
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
            .overlay(
               RoundedRectangle(cornerRadius: 20)
                   .stroke(Color.appBackgroundColor, lineWidth: 1)
            )
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
        .onChange(of: viewModel.didSignInWithApple) { newValue in
            if newValue == true {
                print("Signed in with apple")
            }
        }
        .cornerRadius(20)
        .overlay(
           RoundedRectangle(cornerRadius: 20)
               .stroke(Color.appBackgroundColor, lineWidth: 1)
        )
    }
}
