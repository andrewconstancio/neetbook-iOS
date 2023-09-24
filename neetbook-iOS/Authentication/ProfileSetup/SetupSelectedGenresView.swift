//
//  SetupSelectedGenresView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/26/23.
//

import SwiftUI

struct SetupSelectedGenresView: View {
    @ObservedObject var viewModel: ProfileSetupViewRootViewModel
    @Binding var showProfileSetUpView: Bool
    @State private var threeOrMoreGenresSelected: Bool = false
    
    let genres = ["Romance", "Mystery", "Science Fiction", "Horror",
                  "History", "Biography","Philosophy", "Science", "Thriller", "Self help"]
    
    var body: some View {
        ZStack {
//            Color.appBackgroundColor
            VStack {
                Spacer()
                Text("Select 3 or more genres you are interested in!")
                    .font(.title3)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Spacer()
                TagCloudButtonView(tags: genres,
                            selectedGenres: $viewModel.selectedGenres,
                            threeOrMoreGenresSelected: $threeOrMoreGenresSelected)
                .padding()
                Spacer()
                Spacer()
                Button {
                    viewModel.isCreatingNewUser = true
                    viewModel.addSelectedGenresToUser()
                    Task {
                        try? await viewModel.saveUserProfileImage()
                        try? await viewModel.saveUser()
                        showProfileSetUpView = false
//                        viewModel.isCreatingNewUser = false
                    }
                } label: {
                    Text("Done")
                }
                .buttonStyle(NextButton(isValid: threeOrMoreGenresSelected))
                .disabled(!threeOrMoreGenresSelected)
            }
        }
    }
}

struct SetupSelectedGenresView_Previews: PreviewProvider {
    static var previews: some View {
        SetupSelectedGenresView(viewModel: ProfileSetupViewRootViewModel(), showProfileSetUpView: .constant(false))
    }
}
