//
//  SettingsView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI
import PopupView

struct SettingsView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @State private var showCouldNotDeleteAccountPopup: Bool = false
    
    @State private var showingDeleteAccountPopup = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Link(destination: URL(string: "https://sites.google.com/view/neetbookios/privacy-policy?authuser=0")!, label: {
                Text("Privacy Policy")
                    .frame(height: 45)
                    .frame(width: 300)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .bold()
                    .padding(10)
                    .background(Color.appColorPurple)
                    .cornerRadius(30)
            })
            Link(destination: URL(string: "https://sites.google.com/view/neetbookios/terms-of-service?authuser=0")!, label: {
                Text("Terms Of Service")
                    .frame(height: 45)
                    .frame(width: 300)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .bold()
                    .padding(10)
                    .background(Color.appColorPurple)
                    .cornerRadius(30)
            })
            Link(destination: URL(string: "https://sites.google.com/view/neetbookios/guidelines?authuser=0")!, label: {
                Text("Guidelines")
                    .frame(height: 45)
                    .frame(width: 300)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .bold()
                    .padding(10)
                    .background(Color.appColorPurple)
                    .cornerRadius(30)
            })
            Spacer()
            Button {
                do {
                    try viewModel.signOut()
//                    userStateViewModel.userState = .loggedOut
                } catch {
                    print(error)
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
                .foregroundColor(.primary)
                .padding(10)
                .background(.orange)
                .cornerRadius(30)
            }
            .padding(.top, 30)
            Button {
                showingDeleteAccountPopup = true
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
            }
        }
        .blur(radius: showingDeleteAccountPopup ? 2 : 0)
        .popup(isPresented: $showingDeleteAccountPopup) {
            DeleteAccountPopupView(
                viewModel: viewModel,
                showCouldNotDeleteAccountPopup: $showCouldNotDeleteAccountPopup,
                showingDeleteAccountPopup: $showingDeleteAccountPopup
            )
            .environmentObject(userStateViewModel)
        }
        .popup(isPresented: $showCouldNotDeleteAccountPopup) {
            CouldNoDeleteAccountPopupView(showCouldNotDeleteAccountPopup: $showCouldNotDeleteAccountPopup)
        }
//        .onAppear {
//            viewModel.loadAuthProviders()
//        }
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavBackButtonView(color: .primary, dismiss: self.dismiss))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

//extension SettingsView {
//    private var emailSection: some View {
//        Section {
//            Button("Reset Password") {
//                Task {
//                    do {
//                        try await viewModel.resetPassword()
//                        showSignInView = true
//                        print("password reset")
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            
//            Button("Update Password") {
//                Task {
//                    do {
//                        try await viewModel.updatePassword()
//                        print("password updated")
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            
//            Button("Update Email") {
//                Task {
//                    do {
//                        try await viewModel.updateEmail()
//                        print("email updated")
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//        } header: {
//            Text("Email")
//        }
//    }
//}
