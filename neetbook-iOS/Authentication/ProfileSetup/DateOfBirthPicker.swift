//
//  DateOfBirthPicker.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/17/23.
//

import SwiftUI

struct DateOfBirthPicker: View {
    @State private var date = Date()
    
    var body: some View {
        VStack {
            Text("Birthdate")
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .background(Color.red)
                .fixedSize()
        }
    }
}

struct DateOfBirthPicker_Previews: PreviewProvider {
    static var previews: some View {
        DateOfBirthPicker()
    }
}
