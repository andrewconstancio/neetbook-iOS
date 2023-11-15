//
//  TabBarItem.swift
//  Neetbook_Testing
//
//  Created by Andrew Constancio on 7/7/23.
//

import SwiftUI

enum TabBarItem: Hashable {
    case home, library, search, profile, notificaiton
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .library: return "books.vertical"
        case .search: return "magnifyingglass"
        case .profile: return "person.crop.circle"
        case .notificaiton: return "heart.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .library: return "Library"
        case .search: return "Search"
        case .profile: return "Profile"
        case .notificaiton: return "Notifcation"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Color.white
        case .library: return Color.white
        case .search: return Color.white
        case .profile: return Color.white
        case .notificaiton: return Color.white
        }
    }
}

