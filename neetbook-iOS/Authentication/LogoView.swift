//
//  LogoView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea(.all)
            Text("neetbook.")
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.largeTitle)
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
