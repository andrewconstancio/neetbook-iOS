//
//  NoPhotoBookshelfView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/13/24.
//

import SwiftUI

struct NoPhotoBookshelfView: View {
    @Environment(\.colorScheme) var colorScheme
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? Color.systemGray3 : .white)
                .frame(width: width * 2.4, height: height * 2.4)
            
            Image(systemName: "photo")
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .frame(width: width, height: height)
        }
    }
}

#Preview {
    NoPhotoBookshelfView(width: 20, height: 20)
}
