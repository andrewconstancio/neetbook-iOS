//
//  Color-Ext.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 7/8/23.
//

import SwiftUI

extension Color {
    public static var appBackgroundColor: Color {
//        return Color(red: 0.14, green: 0.14, blue: 0.14)
        return Color(hex: "1b1545")
    }
    
    public static var appNavBarBackgroundColor: Color {
//        return Color(red: 0.18, green: 0.18, blue: 0.18)
        return Color(hex: "2A2B2E")
    }
    
    public static var appColorGreen: Color {
        return Color(hex: "1e555c")
    }
    
    public static var appColorPale: Color {
//        return Color(hex: "f4d8cd")
        return Color(hex: "FF8552")
    }
    
    public static var appColorBuff: Color {
        return Color(hex: "edb183")
    }
    
    public static var appColorRed: Color {
        return Color(hex: "f15152")
    }
    public static var appColorYellow: Color {
        return Color(hex: "d3e03d")
    }
    public static var appColorBeige: Color {
        return Color(hex: "F3F9E3")
    }
    
    public static var appColorCambridgeBlue: Color {
        return Color(hex: "A4C2A8")
    }
    
    public static var appColorWedge: Color {
        return Color(hex: "6D5959")
    }
    
    public static var appColorCeladon: Color {
        return Color(hex: "ABEBD2")
    }
    
    public static var appColorPurple: Color {
        return Color.indigo
    }
    
    public static var appColorOrange: Color {
        return Color(hex: "faa639")
    }
    
    public static var backgroundColor: Color {
        return Color(UIColor(named: "customControlColor")!)
    }
    
    public static var appGradientOne: LinearGradient {
        return LinearGradient(gradient: Gradient(stops: [Gradient.Stop(color: Color(hue: 0.7170674887048193, saturation: 0.7142083960843374, brightness: 0.6054569841867471, opacity: 0.8982492469879518), location: 0.18886718749999998), Gradient.Stop(color: Color(hue: 0.958449030496988, saturation: 0.9845867846385543, brightness: 1.0, opacity: 0.6921916180346386), location: 0.5756310096153845)]), startPoint: UnitPoint.topLeading, endPoint: UnitPoint.bottomTrailing)
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
