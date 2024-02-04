//
//  SettingsView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI
import PopupView

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @State private var showCouldNotDeleteAccountPopup: Bool = false
    @State private var showingDeleteAccountPopup = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Button {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                HStack {
                    Text("Log Out")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(height: 45)
                .frame(width: 300)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.clear, lineWidth: 1)
                )
            }
            .padding(.top, 30)
            Button {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                HStack {
                    Text("Delete Account")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(height: 45)
                .frame(width: 300)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.appColorRed)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.clear, lineWidth: 1)
                )
            }
            Spacer()
            Link(destination: URL(string: "https://sites.google.com/view/neetbookios/privacy-policy?authuser=0")!, label: {
                Text("Privacy Policy")
                    .frame(height: 45)
                    .frame(width: 300)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.clear, lineWidth: 1)
                    )
            })
            Link(destination: URL(string: "https://sites.google.com/view/neetbookios/terms-of-service?authuser=0")!, label: {
                Text("Terms Of Service")
                    .frame(height: 45)
                    .frame(width: 300)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.clear, lineWidth: 1)
                    )
            })
            Link(destination: URL(string: "https://sites.google.com/view/neetbookios/guidelines?authuser=0")!, label: {
                Text("Guidelines")
                    .frame(height: 45)
                    .frame(width: 300)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.clear, lineWidth: 1)
                    )
            })
            
        }
        .blur(radius: showingDeleteAccountPopup ? 2 : 0)
        .popup(isPresented: $showingDeleteAccountPopup) {
            DeleteAccountPopupView(
                viewModel: viewModel,
                showSignInView: $showSignInView,
                showCouldNotDeleteAccountPopup: $showCouldNotDeleteAccountPopup,
                showingDeleteAccountPopup: $showingDeleteAccountPopup
            )
        }
        .popup(isPresented: $showCouldNotDeleteAccountPopup) {
            CouldNoDeleteAccountPopupView(showCouldNotDeleteAccountPopup: $showCouldNotDeleteAccountPopup)
        }
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .black, dismiss: self.dismiss))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        showSignInView = true
                        print("password reset")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("password updated")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update Email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("email updated")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email")
        }
    }
}
