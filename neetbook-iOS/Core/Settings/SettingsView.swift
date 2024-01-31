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
            List {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
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
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
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
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: NavBackButtonView(color: .black, dismiss: self.dismiss))
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
