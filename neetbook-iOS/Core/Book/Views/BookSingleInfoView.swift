//
//  BookSingleInfoView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/16/24.
//

import SwiftUI

struct BookSingleInfoView: View {
    let name: String
    let info: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(name)
                .font(.system(size: 16))
                .bold()
            Text(info)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    BookSingleInfoView(name: "Title", info: "Dune")
}
