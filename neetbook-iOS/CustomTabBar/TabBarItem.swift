//
//  TabBarItem.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//

import SwiftUI

enum TabBarItem: Hashable {
    case home, library, search, profile
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .library: return "books.vertical"
        case .search: return "magnifyingglass"
        case .profile: return "person.crop.circle"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .library: return "Library"
        case .search: return "Search"
        case .profile: return "Profile"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Color.white
        case .library: return Color.white
        case .search: return Color.white
        case .profile: return Color.white
        }
    }
}

