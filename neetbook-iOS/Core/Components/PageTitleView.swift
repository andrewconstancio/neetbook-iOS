//
//  PageTitleView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 1/4/24.
//

import SwiftUI

struct PageTitleView: View {
    let title: String
    var body: some View {
        HStack {
            Spacer()
            Text(title)
            Spacer()
        }
        .frame(height: 55)
    }
}

struct PageTitleView_Previews: PreviewProvider {
    static var previews: some View {
        PageTitleView(title: "Neetbook")
    }
}
