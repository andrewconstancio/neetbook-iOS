//
//  EditProfileView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/24/23.
//

import SwiftUI

struct EditProfileView: View {
    let user: DBUser
    
    @Binding var userUpdated: Bool
    
    @Binding var showProfileEditView: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = EditProfileViewModel()
    
    @State private var shouldShowImagePicker = false
    
    @State var lastScaleValue: CGFloat = 1.0
    
    @State var scale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            // TOP BUTTONS
            HStack {
                Spacer()
                // edit profile text
                Text("Edit Profile")
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                    .offset(x: 20, y: 0)
                Spacer()
                // save button
                Button {
                    viewModel.validate()
                    if viewModel.formInvalid == false {
                        Task {
                            try? await viewModel.saveProfileChanges()
                            userUpdated = true
                            showProfileEditView = false
                        }
                    }
                } label: {
                    Text("Save")
                        .bold()
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
                            
                            Text("#\(viewModel.hashcode)")
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            try? await viewModel.getProfilePicImage(path: user.photoUrl ?? "")
        }
        .onAppear {
            viewModel.setEditProperties(user: user)
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImageMoveAndScaleSheet(croppedImage: $viewModel.profileImage)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Profile")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.validate()
                    if viewModel.formInvalid == false {
                        Task {
                            try? await viewModel.saveProfileChanges()
                            showProfileEditView = false
                        }
                    }
                } label: {
                    Text("Save")
                        .bold()
                }
            }
        }
    }
}
