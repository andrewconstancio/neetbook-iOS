//
//  NavBackBarButtonView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 12/2/23.
//

import SwiftUI

struct NavBackButtonView: View {
    let color: Color
    let dismiss: DismissAction
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .foregroundColor(color)
                .fontWeight(.bold)
        }
    }
}
