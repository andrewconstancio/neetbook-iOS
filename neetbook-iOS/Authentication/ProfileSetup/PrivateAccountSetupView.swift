//
//  PrivateAccountSetupView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/21/23.
//

import SwiftUI

struct PrivateAccountSetupView: View {
    @ObservedObject var viewModel: ProfileSetupViewRootViewModel

    var body: some View {
        VStack {
            Spacer()
            Text("Make account private or public")
                .font(.title3)
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.togglePublicAccount(value: true)
                    }
                } label: {
                    Text("Public")
                }
                .frame(height: 55)
                .frame(width: UIScreen.main.bounds.width / 3)
                .background(viewModel.publicAccount ? Color.yellow : Color.gray)
                .foregroundColor(.white)
                .font(.title3)
                .fontWeight(.medium)
                .cornerRadius(20)
                .padding(.bottom, 20)
                .padding(.horizontal)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.togglePublicAccount(value: false)
                    }
                } label: {
                    Text("Private")
                }
                .frame(height: 55)
                .frame(width: UIScreen.main.bounds.width / 3)
                .background(!viewModel.publicAccount ? Color.yellow : Color.gray)
                .foregroundColor(.white)
                .font(.title3)
                .fontWeight(.medium)
                .cornerRadius(20)
                .padding(.bottom, 20)
                .padding(.horizontal)
            }
            Spacer()
            Button {
                withAnimation(.spring()) {
                    viewModel.setProgressIndexStep += 1
                 }
            } label: {
                Text("Next")
            }
            .buttonStyle(NextButton(isValid: true))
        }
    }
}
