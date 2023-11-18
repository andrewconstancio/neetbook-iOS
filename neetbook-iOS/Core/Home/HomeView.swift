//
//  HomeView.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//

import SwiftUI

struct HomeView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            Color.appBackgroundColor.ignoresSafeArea()
            VStack {
                ScrollView {
                    ForEach(0..<50) { index in
                        Text("This is item #\(index)")
                            .font(.headline)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .padding(5)
                            .id(index)
                    }
                }
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showSignInView: .constant(true))
    }
}
