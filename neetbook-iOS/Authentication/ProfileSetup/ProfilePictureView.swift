//
//  ProfilePictureView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/22/23.
//

import SwiftUI
import PhotosUI

struct ProfilePictureView: View {
    @ObservedObject var viewModel: ProfileSetupViewRootViewModel
    @State private var shouldShowImagePicker = false
    @State var lastScaleValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Add a profile picture")
                .font(.title3)
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            
            Button {
                shouldShowImagePicker
                    .toggle()
            } label: {
                VStack {
                    if let image = self.viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 192, height: 192)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                            .gesture(MagnificationGesture().onChanged { val in
                                        let delta = val / self.lastScaleValue
                                        self.lastScaleValue = val
                                        let newScale = self.scale * delta

                            //... anything else e.g. clamping the newScale
                            }.onEnded { val in
                              // without this the next gesture will be broken
                              self.lastScaleValue = 1.0
                            })
                    } else {
                        Image(systemName: "person.circle")
                            .foregroundColor(Color.appColorPale)
                            .font(.system(size: 96))
                            .padding()
                    }
                }
            }
            Spacer()
            Button {
                withAnimation(.spring()) {
                    viewModel.setProgressIndexStep += 1
                 }
            } label: {
                Text("Next")
            }
        .buttonStyle(NextButton(isValid: viewModel.profileImage != nil))
            .disabled(viewModel.profileImage == nil)
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
//            ImagePicker(image: $viewModel.profileImage)
            ImageMoveAndScaleSheet(croppedImage: $viewModel.profileImage)
        }
    }
}
