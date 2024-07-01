//
//  NotificationComponentView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/7/24.
//

import SwiftUI

struct NotificationComponentView: View {
    
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: NotificationsViewModel
    
    var body: some View {
        Text("hello")
    }
}

//#Preview {
//    NotificationComponentView()
//}
