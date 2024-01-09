//
//  NextButtonView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/21/23.
//

import SwiftUI

struct NextButton: ButtonStyle {
    var isValid: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .foregroundColor(self.isValid ? .white : .white.opacity(0.3))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(self.isValid ? Color.appColorOrange : Color.appColorCeladon.opacity(0.3))
            )
            .font(.title3)
            .fontWeight(.medium)
            .padding(.bottom, 20)
            .padding(.horizontal)
    }
}
