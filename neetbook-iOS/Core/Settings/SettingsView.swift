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
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                        print(showSignInView)
                    } catch {
                        print(error)
                    }
                }
            }
             
            Button(role: .destructive) {
                showingDeleteAccountPopup = true
            } label: {
                Text("Delete Account")
            }

            if viewModel.authProviders.contains(.email) {
                emailSection
            }
    
        }
        .blur(radius: showingDeleteAccountPopup ? 2 : 0)
        .popup(isPresented: $showingDeleteAccountPopup) { // 3
            DeleteAccountPopupView(
                viewModel: viewModel,
                showSignInView: $showSignInView,
                showCouldNotDeleteAccountPopup: $showCouldNotDeleteAccountPopup,
                showingDeleteAccountPopup: $showingDeleteAccountPopup
            )
        }
        .popup(isPresented: $showCouldNotDeleteAccountPopup) { // 3
            CouldNoDeleteAccountPopupView(showCouldNotDeleteAccountPopup: $showCouldNotDeleteAccountPopup)
        }
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .navigationTitle("Settings")
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
