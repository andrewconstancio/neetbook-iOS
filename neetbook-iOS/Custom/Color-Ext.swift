//
//  Color-Ext.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI

extension Color {
    public static var appBackgroundColor: Color {
//        return Color.white
        return Color(red: 0.14, green: 0.14, blue: 0.14)
    }
    
    public static var appColorGreen: Color {
        return Color(hex: "1e555c")
    }
    
    public static var appColorPale: Color {
        return Color(hex: "f4d8cd")
    }
    
    public static var appColorBuff: Color {
        return Color(hex: "edb183")
    }
    
    public static var appColorRed: Color {
        return Color(hex: "f15152")
    }
    public static var appColorYellow: Color {
        return Color(hex: "EDD83D")
    }
    public static var appColorBeige: Color {
        return Color(hex: "F3F9E3")
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
