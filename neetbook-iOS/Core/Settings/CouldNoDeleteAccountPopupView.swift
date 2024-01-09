//
//  CouldNoDeleteAccountPopupView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 1/7/24.
//

import SwiftUI

struct CouldNoDeleteAccountPopupView: View {
    @Binding var showCouldNotDeleteAccountPopup: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading) {
                        Text("Whoops!")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)
                        Text("Could not delete account. Please sign out and back in and retry.")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.black.opacity(0.5))
                    }
                    Button {
                        showCouldNotDeleteAccountPopup = false
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

//struct CouldNoDeleteAccountPopupView_Previews: PreviewProvider {
//    static var previews: some View {
//        CouldNoDeleteAccountPopupView()
//    }
//}
