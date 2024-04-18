//
//  DeleteAccountPopupView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 1/4/24.
//

import SwiftUI
import PopupView

struct DeleteAccountPopupView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @ObservedObject var viewModel: SettingsViewModel
    
    @Binding var showCouldNotDeleteAccountPopup: Bool
    
    @Binding var showingDeleteAccountPopup: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading) {
                        Text("Are you sure?")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)
                        Text("This action cannot be undone.")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.black.opacity(0.5))
                    }
                    VStack(alignment: .leading) {
                        Button {
                            Task {
                                do {
                                    try await viewModel.deleteAccount()
                                } catch {
                                    showCouldNotDeleteAccountPopup = true
                                    showingDeleteAccountPopup = false
                                }
                            }
                        } label: {
                            HStack {
                                Text("Delete")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 300, height: 35)
                            .font(.system(size: 14))
                            .padding(10)
                            .background(Color.appColorRed)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.clear, lineWidth: 1)
                            )
                        }
                        
                        Button {
                            showingDeleteAccountPopup = false
                        } label: {
                            HStack {
                                Text("Close")
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                            .frame(width: 300, height: 35)
                            .font(.system(size: 14))
                            .padding(10)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
        .padding(.horizontal, 40)
    }
}

//struct DeleteAccountPopupView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeleteAccountPopupView()
//    }
//}
