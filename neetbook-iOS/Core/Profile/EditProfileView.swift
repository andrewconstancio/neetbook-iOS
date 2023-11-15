//
//  EditProfileView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/24/23.
//

import SwiftUI

struct EditProfileView: View {
    let user: DBUser
    @Binding var showProfileEditView: Bool
    
    @StateObject private var viewModel = EditProfileViewModel()
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @State private var shouldShowImagePicker = false
    @State var lastScaleValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            // TOP BUTTONS
            HStack {
                // cancel button
                Button {
                    showProfileEditView = false
                } label: {
                    Text("Cancel")
                }
                Spacer()
                
                // edit profile text
                Text("Edit Profile")
                    .fontWeight(.bold)
                Spacer()
                
                // save button
                Button {
                    viewModel.validate()
                    if viewModel.formInvalid == false {
                        Task {
                            try? await viewModel.saveProfileChanges()
                            if let profileImage = viewModel.profileImage {
                                currentUserViewModel.setCurrentUserPhoto(image: profileImage)
                            }
                            showProfileEditView = false
                        }
                    }
                } label: {
                    Text("Save")
                }
            }
            .padding()
            
            Spacer()
            
            // CHANGE PROFILE PIC
            Button {
                shouldShowImagePicker.toggle()
            } label: {
                VStack {
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .overlay(
                                Image(systemName: "camera")
                                    .font(.system(size: 60))
                                    .foregroundColor(.black.opacity(0.9))
                            )
                            .frame(width: 125, height: 125)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                            .gesture(MagnificationGesture().onChanged { val in
                                let delta = val / self.lastScaleValue
                                self.lastScaleValue = val
                            }.onEnded { val in
                                self.lastScaleValue = 1.0
                            })
                    }
                }
            }
            Spacer()
       
            Form {
                Section {
                    if viewModel.invalidDisplayName {
                        Text("This field can not be empty!")
                            .fontWeight(.light)
                            .foregroundColor(.red)
                    }
                    VStack(alignment: .leading) {
                        Text("Name")
                            .foregroundColor(.primary)
                            .fontWeight(.bold)

                        TextField("", text: $viewModel.displayName)
                    }
                }
                
                Section {
                    if viewModel.invalidUsername {
                        Text("This field can not be empty!")
                            .fontWeight(.light)
                            .foregroundColor(.red)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Username")
                            .foregroundColor(.primary)
                            .fontWeight(.bold)

                        HStack {
                            TextField("", text: $viewModel.username)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            
                            Text("#\(viewModel.hashCode)")
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .task {
            try? await viewModel.getProfilePicImage(path: user.photoUrl ?? "")
        }
        .onAppear {
            viewModel.setEditProperties(user: user)
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImageMoveAndScaleSheet(croppedImage: $viewModel.profileImage)
        }
    }
}
