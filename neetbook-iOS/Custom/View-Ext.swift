//
//  View-Ext.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/14/23.
//

import SwiftUI
import UIKit

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func placeholder<Content: View>(
          when shouldShow: Bool,
          alignment: Alignment = .leading,
          @ViewBuilder placeholder: () -> Content) -> some View {

          ZStack(alignment: alignment) {
              placeholder().opacity(shouldShow ? 1 : 0)
              self
          }
      }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
