//
//  GenreContentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/3/24.
//

import SwiftUI

struct GenreContentView: View {
    
    @ObservedObject var viewModel: GenreContentViewModel
    
    var body: some View {
        VStack {
            Text("\(viewModel.genre)")
                .foregroundColor(.primary)
        }
    }
}

//#Preview {
//    GenreContentView( genre: "Thriller")
//}
