//
//  DataOfBirthView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/21/23.
//

import SwiftUI

struct DataOfBirthView: View {
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
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .fixedSize()
                .onChange(of: viewModel.dateOfBirth) { newValue in
                    viewModel.checkDateOfBirth(dob: newValue)
                }
                .accentColor(.white)
            
            Spacer()
            Button {
                withAnimation(.spring()) {
                    viewModel.setProgressIndexStep += 1
                 }
            } label: {
                Text("Next")
            }
            .buttonStyle(NextButton(isValid: viewModel.validDateOfBirth))
            .disabled(!viewModel.validDateOfBirth)
        }
    }
}
