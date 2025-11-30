//
//  Untitled.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//
import SwiftUI

struct CommentActionButtonModifier: ViewModifier {
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .frame(width: 300, height: 55)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(10)
            .background(backgroundColor)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.clear, lineWidth: 1)
            )
    }
}
