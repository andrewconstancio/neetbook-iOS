//
//  DataOfBirthView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/21/23.
//

import SwiftUI

struct DataOfBirthView: View {
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @ObservedObject var viewModel: ProfileSetupViewRootViewModel
    
    @Environment(\.colorScheme) var colorScheme

    var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let max = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return min...max
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Birthdate")
                .font(.title3)
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            DatePicker(
                "",
                selection: $viewModel.dateOfBirth,
                in: dateClosedRange,
                displayedComponents: .date
            )
            .colorScheme(.dark)
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .fixedSize()
            .onChange(of: viewModel.dateOfBirth) { newValue in
                viewModel.checkDateOfBirth(dob: newValue)
            }
            
            Spacer()
            Button {
                viewModel.isCreatingNewUser = true
                viewModel.addSelectedGenresToUser()
                Task {
                    try? await viewModel.saveUserProfileImage()
                    try? await viewModel.saveUser()
                    try? await userStateViewModel.fetchUser()
                }
            } label: {
                Text("Done")
            }
            .buttonStyle(NextButton(isValid: viewModel.validDateOfBirth))
            .disabled(!viewModel.validDateOfBirth)
        }
    }
}
