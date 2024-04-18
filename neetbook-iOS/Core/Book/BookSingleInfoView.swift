//
//  BookSingleInfoView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/16/24.
//

import SwiftUI

struct BookSingleInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let name: String
    let info: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(name)
                .font(.system(size: 14))
                .bold()
            Text(info)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    BookSingleInfoView(name: "Title", info: "Dune")
}
